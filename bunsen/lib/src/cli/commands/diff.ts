import { loadConfig } from '../../core/config/loader.ts'
import { logger } from '../../utils/logger.ts'

export interface DiffCommandOptions {
  config?: string
  profile?: string
  symlinksOnly?: boolean
  envOnly?: boolean
  karabinerOnly?: boolean
  espansoOnly?: boolean
  packagesOnly?: boolean
}

export async function diffCommand(options: DiffCommandOptions): Promise<void> {
  try {
    const loaded = await loadConfig({
      configPath: options.config,
      profile: options.profile,
    })

    const config = loaded.config
    const { context } = loaded

    logger.success('Configuration is valid')
    if (context.profile) {
      logger.info(`Profile: ${context.profile}`)
      if (!context.exists) {
        logger.warn('Profile not defined in config, using base config only')
      }
    }

    logger.plain('')
    logger.info('Configuration Summary:')

    if (config.symlinks) {
      const count = Object.keys(config.symlinks).length
      logger.plain(`  Symlinks: ${count} entries`)
    }
    if (config.env) {
      const varCount = Object.keys(config.env.variables || {}).length
      logger.plain(`  Environment: ${varCount} variables`)
    }
    if (config.karabiner) {
      logger.plain('  Karabiner: configured')
    }
    if (config.espanso) {
      logger.plain('  Espanso: configured')
    }
    if (config.packages) {
      logger.plain('  Packages: configured')
    }
  } catch (error) {
    logger.error('Failed to load configuration')
    if (error instanceof Error) {
      logger.plain(error.message)
    }
    process.exit(1)
  }
}
