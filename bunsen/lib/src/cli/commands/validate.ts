import { loadConfig } from '../../core/config/loader.ts'
import { logger } from '../../utils/logger.ts'

export interface ValidateOptions {
  config?: string
  profile?: string
}

export async function validateCommand(options: ValidateOptions) {
  try {
    const loaded = await loadConfig({
      configPath: options.config,
      profile: options.profile,
    })

    logger.success('Configuration is valid')

    if (loaded.context.profile) {
      logger.info(`Profile: ${loaded.context.profile}`)
      logger.info(`Source: ${loaded.context.source}`)
      logger.info(`Exists: ${loaded.context.exists ? 'yes' : 'no (using base config)'}`)
    }

    // List available profiles
    if (loaded.raw.profiles) {
      const names = Object.keys(loaded.raw.profiles)
      logger.plain(`Available profiles: ${names.join(', ')}`)
    }
  } catch (error) {
    logger.error('Configuration validation failed')
    if (error instanceof Error) {
      logger.plain(error.message)
    }
    process.exit(1)
  }
}
