import ora from 'ora'
import { loadConfig } from '../../core/config/loader.ts'
import { normalizeSymlinks, createSymlink } from '../../core/symlink/manager.ts'
import { generateEnvConfig } from '../../core/generators/env.ts'
import { generateKarabinerConfig } from '../../core/generators/karabiner.ts'
import { generateEspansoConfig } from '../../core/generators/espanso.ts'
import { generatePackagesConfig } from '../../core/generators/packages.ts'
import { updateLastApplied } from '../../core/state/storage.ts'
import { logger } from '../../utils/logger.ts'

export interface ApplyOptions {
  config?: string
  profile?: string
  dryRun?: boolean
  force?: boolean
  symlinksOnly?: boolean
  envOnly?: boolean
  karabinerOnly?: boolean
  espansoOnly?: boolean
  packagesOnly?: boolean
}

export async function applyCommand(options: ApplyOptions) {
  const { dryRun = false, force = false } = options
  const spinner = ora('Loading configuration...').start()

  let loadedConfig
  try {
    loadedConfig = await loadConfig({
      configPath: options.config,
      profile: options.profile,
    })
    const profileInfo = loadedConfig.context.profile ? ` (profile: ${loadedConfig.context.profile})` : ''
    spinner.succeed(`Configuration loaded${profileInfo}`)
  } catch (error) {
    logger.error(error)
    spinner.fail('Failed to load configuration')
    process.exit(1)
  }

  const config = loadedConfig.config
  const { context } = loadedConfig

  // Show profile info if selected
  if (context.profile) {
    const sourceLabel = {
      cli: 'CLI parameter',
      env: 'environment variable',
      hostname: 'hostname match',
      default: 'default profile',
      freeform: 'free-form',
    }[context.source]

    logger.info(`Profile: ${context.profile} (${sourceLabel})`)
    if (!context.exists) {
      logger.warn('Profile not defined in config, using base config only')
    }
  }

  // Run global hooks beforeApply
  if (config.hooks?.beforeApply) {
    try {
      await config.hooks.beforeApply()
    } catch (error) {
      logger.error('beforeApply hook failed')
      if (error instanceof Error) {
        logger.plain(error.message)
      }
    }
  }

  const applyAll =
    !options.symlinksOnly &&
    !options.envOnly &&
    !options.karabinerOnly &&
    !options.espansoOnly &&
    !options.packagesOnly

  // Apply global packages
  if ((applyAll || options.packagesOnly) && config.packages) {
    spinner.start('Installing packages...')
    try {
      await generatePackagesConfig(config.packages, { dryRun })
      if (dryRun) {
        spinner.info('[DRY RUN] Would install packages')
      } else {
        spinner.succeed('Installed packages')
      }
    } catch (error) {
      spinner.fail('Failed to install packages')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Apply symlinks
  if ((applyAll || options.symlinksOnly) && config.symlinks && Object.keys(config.symlinks).length > 0) {
    spinner.start('Creating symlinks...')
    const normalized = normalizeSymlinks(config.symlinks)
    let successCount = 0
    const createdSymlinks: Array<{ target: string; source: string }> = []

    for (const link of normalized) {
      const success = await createSymlink(link, { dryRun, force, silent: true })
      if (success) {
        successCount++
        createdSymlinks.push({ target: link.target, source: link.source })
      }
    }

    if (dryRun) {
      spinner.info(`[DRY RUN] Would create ${successCount}/${normalized.length} symlinks`)
    } else {
      spinner.succeed(`Created ${successCount}/${normalized.length} symlinks`)
    }
    if (createdSymlinks.length > 0) {
      for (const link of createdSymlinks) {
        logger.plain(`\t${link.target} -> ${link.source}`)
      }
    }
  }

  // Apply env
  if ((applyAll || options.envOnly) && (config.env || context.profile)) {
    spinner.start(config.env ? 'Generating environment variables...' : 'Setting profile environment variable...')
    try {
      const envConfig = config.env || {
        shells: ['zsh', 'bash'],
        variables: {},
      }
      // @ts-expect-error - EnvConfig vs minimal config
      await generateEnvConfig(envConfig, { dryRun, profileName: context.profile || undefined })
      if (dryRun) {
        spinner.info(config.env ? '[DRY RUN] Would generate env config' : '[DRY RUN] Would set profile environment variable')
      } else {
        spinner.succeed(config.env ? 'Generated environment variables' : 'Set profile environment variable')
      }
    } catch (error) {
      spinner.fail(config.env ? 'Failed to generate env config' : 'Failed to set BUNSEN_PROFILE')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Apply karabiner
  if ((applyAll || options.karabinerOnly) && config.karabiner) {
    spinner.start('Generating Karabiner configuration...')
    try {
      await generateKarabinerConfig(config.karabiner, { dryRun })
      if (dryRun) {
        spinner.info('[DRY RUN] Would generate Karabiner config')
      } else {
        spinner.succeed('Generated Karabiner configuration')
      }
    } catch (error) {
      spinner.fail('Failed to generate Karabiner config')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Apply espanso
  if ((applyAll || options.espansoOnly) && config.espanso) {
    spinner.start('Generating Espanso configuration...')
    try {
      await generateEspansoConfig(config.espanso, { dryRun })
      if (dryRun) {
        spinner.info('[DRY RUN] Would generate Espanso config')
      } else {
        spinner.succeed('Generated Espanso configuration')
      }
    } catch (error) {
      spinner.fail('Failed to generate Espanso config')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Update state with profile info
  if (!dryRun && context.profile) {
    await updateLastApplied(context.profile)
  }

  // Run global hooks afterApply
  if (config.hooks?.afterApply) {
    try {
      await config.hooks.afterApply()
    } catch (error) {
      logger.error('afterApply hook failed')
      if (error instanceof Error) {
        logger.plain(error.message)
      }
    }
  }

  logger.plain('')
  if (dryRun) {
    logger.success('[DRY RUN] Complete - no changes were made')
  } else {
    logger.success('Configuration applied successfully!')
  }
}
