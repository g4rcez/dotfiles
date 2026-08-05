import ora from 'ora'
import { loadConfig } from '../../core/config/loader.ts'
import { normalizeSymlinks, createSymlink } from '../../core/symlink/manager.ts'
import { generateEnvConfig } from '../../core/generators/env.ts'
import { generateKarabinerConfig } from '../../core/generators/karabiner.ts'
import { generateEspansoConfig } from '../../core/generators/espanso.ts'
import { generatePackagesConfig } from '../../core/generators/packages.ts'
import { updateLastApplied, getActiveProfile } from '../../core/state/storage.ts'
import { logger } from '../../utils/logger.ts'
import { colors } from '../../utils/colors.ts'

export interface ProfileCommandOptions {
  config?: string
  force?: boolean
  dryRun?: boolean
}

export async function profileCommand(
  profileName: string,
  options: ProfileCommandOptions
) {
  const { dryRun = false, force = false } = options
  const spinner = ora('Loading configuration...').start()

  // Load config with explicit profile
  let loaded
  try {
    loaded = await loadConfig({ configPath: options.config, profile: profileName })
    spinner.succeed('Configuration loaded')
  } catch (error) {
    spinner.fail('Failed to load configuration')
    if (error instanceof Error) {
      logger.plain(error.message)
    }
    process.exit(1)
  }

  const config = loaded.config
  const { context } = loaded

  // Show profile info
  logger.plain('')
  if (!context.exists) {
    logger.warn(`Profile '${profileName}' not defined in config`)
    logger.info('Using base configuration only')
  } else if (context.exists && loaded.raw.profiles?.[profileName]?.extends) {
    logger.info(`Profile '${profileName}' extends: ${loaded.raw.profiles[profileName].extends}`)
  } else {
    logger.info(`Profile '${profileName}' is defined`)
  }

  // Get current active profile
  const currentProfile = await getActiveProfile()

  // Show profile change
  logger.plain('')
  if (currentProfile && currentProfile !== profileName) {
    logger.info(`Switching from: ${colors.cyan(currentProfile)}`)
  }
  logger.info(`Setting profile: ${colors.green(profileName)}`)

  // Apply config with profile name
  spinner.start('Applying configuration...')

  // Apply global packages
  if (config.packages) {
    try {
      await generatePackagesConfig(config.packages, { dryRun })
    } catch (error) {
      spinner.fail('Failed to install packages')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Apply symlinks
  if (config.symlinks && Object.keys(config.symlinks).length > 0) {
    const normalized = normalizeSymlinks(config.symlinks)
    let successCount = 0

    for (const link of normalized) {
      const success = await createSymlink(link, { dryRun, force, silent: true })
      if (success) successCount++
    }

    if (!dryRun) {
      spinner.succeed(`Created ${successCount}/${normalized.length} symlinks`)
    }
  }

  // Apply env with profile name (ensures BUNSEN_PROFILE is set)
  if (config.env) {
    try {
      await generateEnvConfig(config.env, { dryRun, profileName })
      if (!dryRun) {
        spinner.succeed('Generated environment variables')
      }
    } catch (error) {
      spinner.fail('Failed to generate env config')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  } else {
    // Even if no env config, ensure BUNSEN_PROFILE is set
    try {
      const minimalEnv = {
        shells: ['zsh' as const, 'bash' as const],
        variables: {} as Record<string, string | string[]>,
      }
      await generateEnvConfig(minimalEnv, { dryRun, profileName })
      if (!dryRun) {
        spinner.succeed('Set profile environment variable')
      }
    } catch (error) {
      spinner.fail('Failed to set BUNSEN_PROFILE')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Apply karabiner
  if (config.karabiner) {
    try {
      await generateKarabinerConfig(config.karabiner, { dryRun })
      if (!dryRun) {
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
  if (config.espanso) {
    try {
      await generateEspansoConfig(config.espanso, { dryRun })
      if (!dryRun) {
        spinner.succeed('Generated Espanso configuration')
      }
    } catch (error) {
      spinner.fail('Failed to generate Espanso config')
      if (error instanceof Error) {
        logger.error(error.message)
      }
    }
  }

  // Run hooks if not dry-run
  if (!dryRun) {
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

    await updateLastApplied(profileName)

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

    spinner.stop()
  }

  // Show completion message
  logger.plain('')
  if (dryRun) {
    logger.success(`[DRY RUN] Profile '${profileName}' would be applied`)
  } else {
    logger.success(`Profile '${profileName}' has been set and applied`)
    logger.plain('')
    logger.plain(`To use this profile in your current shell, run:`)
    logger.plain(`  ${colors.cyan(`export BUNSEN_PROFILE="${profileName}"`)}`)
    logger.plain('')
    logger.plain(`Or restart your shell to load it automatically.`)
  }
}
