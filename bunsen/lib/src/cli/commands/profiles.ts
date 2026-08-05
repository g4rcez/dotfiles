import { loadConfig } from '../../core/config/loader.ts'
import { getActiveProfile } from '../../core/state/storage.ts'
import { logger } from '../../utils/logger.ts'
import { colors } from '../../utils/colors.ts'

export interface ProfilesCommandOptions {
  config?: string
}

export async function profilesCommand(options: ProfilesCommandOptions) {
  try {
    const loaded = await loadConfig({ configPath: options.config })

    const profiles = loaded.raw.profiles
    if (!profiles || Object.keys(profiles).length === 0) {
      logger.info('No profiles defined in configuration')
      return
    }

    logger.success('Available profiles:')
    logger.plain('')

    for (const [name, profile] of Object.entries(profiles)) {
      let line = `  ${colors.cyan(name)}`
      if (profile.extends) {
        const extendsText = `(extends: ${profile.extends})`
        line += ` ${colors.gray(extendsText)}`
      }
      if (profile.hostname) {
        const hostnames = Array.isArray(profile.hostname)
          ? profile.hostname.join(', ')
          : profile.hostname
        const hostnameText = `[${hostnames}]`
        line += ` ${colors.gray(hostnameText)}`
      }
      logger.plain(line)
    }

    // Show current active profile
    const active = await getActiveProfile()
    if (active) {
      logger.plain('')
      logger.info(`Active profile: ${colors.green(active)}`)
    }
  } catch (error) {
    logger.error('Failed to load configuration')
    if (error instanceof Error) {
      logger.plain(error.message)
    }
    process.exit(1)
  }
}
