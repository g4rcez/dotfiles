import ora from 'ora'
import { applyConfiguration, type ApplySelection } from '../../core/apply/orchestrator.ts'
import { loadConfig } from '../../core/config/loader.ts'
import { logger } from '../../utils/logger.ts'

export interface ApplyOptions extends ApplySelection {
  config?: string
  profile?: string
  dryRun?: boolean
  force?: boolean
}

export async function applyCommand(
  options: ApplyOptions,
  runApply: typeof applyConfiguration = applyConfiguration
): Promise<void> {
  const { dryRun = false, force = false } = options
  const spinner = ora('Loading configuration...').start()

  let loaded
  try {
    loaded = await loadConfig({ configPath: options.config, profile: options.profile })
  } catch (error) {
    spinner.fail('Failed to load configuration')
    throw error
  }

  const { config, context } = loaded
  const profileInfo = context.profile ? ` (profile: ${context.profile})` : ''
  spinner.succeed(`Configuration loaded${profileInfo}`)

  if (context.profile) {
    const sourceLabel = {
      cli: 'CLI parameter',
      env: 'environment variable',
      hostname: 'hostname match',
      default: 'default profile',
      freeform: 'free-form',
    }[context.source]
    logger.info(`Profile: ${context.profile} (${sourceLabel})`)
    if (!context.exists) logger.warn('Profile not defined in config, using base config only')
  }

  spinner.start(dryRun ? 'Previewing configuration...' : 'Applying configuration...')
  try {
    const summary = await runApply({
      config,
      context,
      dryRun,
      force,
      symlinksOnly: options.symlinksOnly,
      envOnly: options.envOnly,
      karabinerOnly: options.karabinerOnly,
      espansoOnly: options.espansoOnly,
      packagesOnly: options.packagesOnly,
    })
    if (summary.symlinks.total > 0) {
      spinner.succeed(
        `${dryRun ? 'Would create' : 'Created'} ${summary.symlinks.completed}/${summary.symlinks.total} symlinks`
      )
      for (const link of summary.symlinks.links) logger.plain(`\t${link.target} -> ${link.source}`)
    } else {
      spinner.stop()
    }
  } catch (error) {
    spinner.fail('Configuration was only partially applied')
    throw error
  }

  logger.plain('')
  logger.success(
    dryRun ? '[DRY RUN] Complete - no changes were made' : 'Configuration applied successfully!'
  )
}
