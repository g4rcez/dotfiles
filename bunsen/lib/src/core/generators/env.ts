import { homedir } from 'node:os'
import { resolve } from 'node:path'
import { writeFile } from '../../utils/fs.ts'
import {
  getShellConfigPath,
  injectIntoShellConfig,
  hasBunsenIntegration,
} from '../../utils/shell.ts'
import { updateEnvState } from '../state/storage.ts'
import { expandPath } from '../symlink/resolver.ts'
import { logger } from '../../utils/logger.ts'
import type { EnvConfig } from '../config/types.ts'

function generateExports(
  variables: Record<string, string | string[]>,
  profileName?: string
): string {
  const lines: string[] = ['#!/bin/bash', '']

  // Add BUNSEN_PROFILE if provided
  if (profileName) {
    lines.push(`export BUNSEN_PROFILE="${profileName}"`)
  }

  // Mark as loaded to prevent duplicate sourcing
  lines.push('export BUNSEN_ENV_LOADED="true"')


  const home = homedir()
  for (const [key, value] of Object.entries(variables)) {
    if (Array.isArray(value)) {
      const joined = value
        .map((v) => {
          if (v === '$PATH' || v === '${PATH}') {
            return '$PATH'
          }
          return expandPath(v, home).replace(home, '$HOME')
        })
        .join(':')
      lines.push(`export ${key}="${joined}"`)
    } else {
      const expanded = expandPath(value, home).replace(home, '$HOME')
      lines.push(`export ${key}="${expanded}"`)
    }
  }

  return lines.join('\n') + '\n'
}

/**
 * Generates environment variable configuration
 */
export async function generateEnvConfig(
  config: EnvConfig,
  options: { dryRun?: boolean; profileName?: string } = {}
): Promise<void> {
  const { dryRun = false, profileName } = options
  const home = homedir()
  const exportFile = config.exportFile
    ? expandPath(config.exportFile, home)
    : '$HOME/.config/bunsen/env.sh'
  const content = generateExports(config.variables, profileName)
  if (dryRun) {
    logger.info(`[DRY RUN] Would write env exports to: ${exportFile}`)
    logger.debug('Export content:')
    logger.plain(content)
  } else {
    await writeFile(exportFile, content)
    logger.success(`Generated env exports: ${exportFile}`)
  }
  const shells = config.shells || ['zsh', 'bash']
  const injectedShells: string[] = []
  for (const shell of shells) {
    const configPath = getShellConfigPath(shell)
    if (dryRun) {
      const hasIntegration = await hasBunsenIntegration(configPath)
      if (hasIntegration) {
        logger.info(`[DRY RUN] Would update ${shell} config: ${configPath}`)
      } else {
        logger.info(`[DRY RUN] Would inject into ${shell} config: ${configPath}`)
      }
    } else {
      try {
        await injectIntoShellConfig(configPath, exportFile)
        injectedShells.push(configPath)
        logger.success(`Injected into ${shell} config: ${configPath}`)
      } catch (error) {
        logger.error(`Failed to inject into ${shell} config: ${error}`)
      }
    }
  }
  if (!dryRun) {
    await updateEnvState(exportFile, injectedShells)
  }
}
