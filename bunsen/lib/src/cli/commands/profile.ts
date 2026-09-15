import ora from 'ora'
import { applyConfiguration } from '../../core/apply/orchestrator.ts'
import { loadConfig } from '../../core/config/loader.ts'
import { getActiveProfile } from '../../core/state/storage.ts'
import { colors } from '../../utils/colors.ts'
import { logger } from '../../utils/logger.ts'

export interface ProfileCommandOptions {
  config?: string
  force?: boolean
  dryRun?: boolean
}

export async function profileCommand(
  profileName: string,
  options: ProfileCommandOptions
): Promise<void> {
  const { dryRun = false, force = false } = options
  const spinner = ora('Loading configuration...').start()

  let loaded
  try {
    loaded = await loadConfig({ configPath: options.config, profile: profileName })
  } catch (error) {
    spinner.fail('Failed to load configuration')
    throw error
  }
  spinner.succeed('Configuration loaded')

  const { config, context } = loaded
  logger.plain('')
  if (!context.exists) {
    logger.warn(`Profile '${profileName}' not defined in config`)
    logger.info('Using base configuration only')
  } else if (loaded.raw.profiles?.[profileName]?.extends) {
    logger.info(`Profile '${profileName}' extends: ${loaded.raw.profiles[profileName].extends}`)
  } else {
    logger.info(`Profile '${profileName}' is defined`)
  }

  const currentProfile = await getActiveProfile()
  logger.plain('')
  if (currentProfile && currentProfile !== profileName) {
    logger.info(`Switching from: ${colors.cyan(currentProfile)}`)
  }
  logger.info(`Setting profile: ${colors.green(profileName)}`)

  spinner.start(dryRun ? 'Previewing configuration...' : 'Applying configuration...')
  try {
    const summary = await applyConfiguration({ config, context, dryRun, force })
    if (summary.symlinks.total > 0) {
      spinner.succeed(
        `${dryRun ? 'Would create' : 'Created'} ${summary.symlinks.completed}/${summary.symlinks.total} symlinks`
      )
    } else {
      spinner.stop()
    }
  } catch (error) {
    spinner.fail(`Profile '${profileName}' was only partially applied`)
    throw error
  }

  logger.plain('')
  if (dryRun) {
    logger.success(`[DRY RUN] Profile '${profileName}' would be applied`)
    return
  }

  logger.success(`Profile '${profileName}' has been set and applied`)
  logger.plain('')
  logger.plain('To use this profile in your current shell, run:')
  logger.plain(`  ${colors.cyan(`export BUNSEN_PROFILE="${profileName}"`)}`)
  logger.plain('')
  logger.plain('Or restart your shell to load it automatically.')
}
