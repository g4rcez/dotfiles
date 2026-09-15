import { loadConfig } from '../../core/config/loader.ts'
import { calculateDiff } from '../../core/diff/calculator.ts'
import { formatDiffResult } from '../../core/diff/formatter.ts'
import type { DiffOptions } from '../../core/diff/types.ts'
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
  const filters = [
    options.symlinksOnly,
    options.envOnly,
    options.karabinerOnly,
    options.espansoOnly,
    options.packagesOnly,
  ].filter(Boolean)
  if (filters.length > 1) {
    throw new Error('Choose only one --*-only filter at a time')
  }

  const loaded = await loadConfig({ configPath: options.config, profile: options.profile })
  const diffOptions: DiffOptions = {
    profileName: loaded.context.profile || undefined,
    symlinksOnly: options.symlinksOnly,
    envOnly: options.envOnly,
    karabinerOnly: options.karabinerOnly,
    espansoOnly: options.espansoOnly,
    packagesOnly: options.packagesOnly,
  }
  const result = await calculateDiff(loaded.config, diffOptions)

  if (loaded.context.profile) {
    logger.info(`Profile: ${loaded.context.profile}`)
    if (!loaded.context.exists) logger.warn('Profile not defined in config, using base config only')
  }
  logger.plain(formatDiffResult(result))
}
