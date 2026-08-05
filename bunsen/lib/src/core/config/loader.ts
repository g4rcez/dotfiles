import { existsSync } from 'node:fs'
import { homedir } from 'node:os'
import { dirname, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'
import { logger } from '../../utils/logger.ts'
import { DotfilesConfigSchema } from './schema.ts'
import { selectProfile, getEffectiveConfig } from './profile.ts'
import type { DotfilesConfig, ProfileContext } from './types.ts'

/**
 * Options for loading configuration
 */
export interface LoadConfigOptions {
  /** Path to config file */
  configPath?: string
  /** Profile name (optional label for tracking which profile is active) */
  profile?: string
}

/**
 * Loaded configuration with profile resolution
 */
export interface LoadedConfig {
  /** Raw config as loaded from file */
  raw: DotfilesConfig
  /** Resolved config (base + profile merged) */
  config: DotfilesConfig
  /** Profile selection context */
  context: ProfileContext
  /** Directory containing the config file */
  configDir: string
}

export function findConfigFile(configPath?: string): string | null {
  const searchPaths = configPath
    ? [resolve(configPath)]
    : [
        resolve(process.cwd(), 'dotfiles.config.ts'),
        resolve(process.cwd(), 'dotfiles.config.js'),
        resolve(homedir(), '.config/bunsen/dotfiles.config.ts'),
        resolve(homedir(), '.config/bunsen/dotfiles.config.js'),
        resolve(homedir(), 'dotfiles/dotfiles.config.ts'),
        resolve(homedir(), 'dotfiles/dotfiles.config.js'),
        resolve(homedir(), '.dotfiles/dotfiles.config.ts'),
        resolve(homedir(), '.dotfiles/dotfiles.config.js'),
      ]

  for (const path of searchPaths) {
    if (existsSync(path)) {
      logger.debug(`Found config file: ${path}`)
      return path
    }
  }
  return null
}

/**
 * Loads configuration with profile selection and resolution
 */
export async function loadConfig(options: LoadConfigOptions = {}): Promise<LoadedConfig> {
  const configFile = findConfigFile(options.configPath)
  if (!configFile) {
    throw new Error(
      'Could not find dotfiles.config.ts or dotfiles.config.js.\n' +
        'Search paths:\n' +
        '  - ./dotfiles.config.ts\n' +
        '  - ~/.config/bunsen/dotfiles.config.ts\n' +
        '  - ~/dotfiles/dotfiles.config.ts\n' +
        '  - ~/.dotfiles/dotfiles.config.ts\n' +
        'Run "bunsen init" to create a new configuration file.'
    )
  }
  logger.info(`Using config file: ${configFile}`)
  try {
    const fileUrl = pathToFileURL(configFile).href
    const module = await import(fileUrl)
    const rawConfig = module.default
    if (!rawConfig) {
      throw new Error('Configuration file must have a default export')
    }
    const result = DotfilesConfigSchema.safeParse(rawConfig)
    if (!result.success) {
      const errors = result.error.issues
        .map((err) => `  - ${String(err.path.join('.'))}:${err.message}`)
        .join('\n')
      throw new Error(`Configuration validation failed:\n${errors}`)
    }

    const raw = result.data as DotfilesConfig

    logger.debug('Configuration loaded and validated successfully')

    // Select profile with priority: CLI > ENV > hostname > default
    const context = selectProfile(raw, {
      cliProfile: options.profile,
      envProfile: process.env.BUNSEN_PROFILE,
    })

    // Get effective config (base + profile merged)
    const config = getEffectiveConfig(raw, context)

    return {
      raw,
      config,
      context,
      configDir: dirname(configFile),
    }
  } catch (error) {
    if (error instanceof Error) {
      if (error.message.includes('TypeScript')) {
        throw new Error(
          'Failed to load TypeScript config file.\n' +
            'Make sure you are using Bun 1.0.0 or higher.\n' +
            'Bun natively supports TypeScript without any configuration.\n\n' +
            'Or convert your config to JavaScript (.js).'
        )
      }
      throw error
    }
    throw error
  }
}

export function getConfigDir(configPath?: string): string {
  const configFile = findConfigFile(configPath)
  if (!configFile) {
    throw new Error('Could not find configuration file')
  }
  return dirname(configFile)
}
