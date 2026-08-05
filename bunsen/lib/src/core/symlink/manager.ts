import { symlink, unlink, rm } from 'fs/promises'
import { resolvePath, validatePath } from './resolver.ts'
import { checkConflict, createBackup, type ConflictResolution } from './conflict.ts'
import {
  pathExists,
  isDirectory,
  ensureParentDir,
  calculateChecksum,
  getPathType,
} from '../../utils/fs.ts'
import { addSymlinkToState, removeSymlinkFromState } from '../state/storage.ts'
import { logger } from '../../utils/logger.ts'
import type { NormalizedSymlink } from '../config/types.ts'
import { homedir } from 'node:os'

export interface SymlinkOptions {
  dryRun?: boolean
  force?: boolean
  silent?: boolean
}

export async function createSymlink(
  link: NormalizedSymlink,
  options: SymlinkOptions = {}
): Promise<boolean> {
  const { dryRun = false, force = false, silent = false } = options
  const home = homedir()
  const target = resolvePath(link.target, home)
  const source = resolvePath(link.source, home)
  if (!validatePath(target) || !validatePath(source)) {
    logger.error(`Invalid path detected (possible directory traversal): ${target} -> ${source}`)
    return false
  }
  if (!pathExists(source)) {
    logger.error(`Source does not exist: ${source}`)
    return false
  }
  const conflict = await checkConflict(target, source)
  if (conflict.isCorrectSymlink) {
    logger.debug(`Symlink already correct: ${target} -> ${source}`)
    return true
  }
  if (conflict.exists) {
    let resolution: ConflictResolution
    if (force || link.force) {
      resolution = 'overwrite'
    } else if (link.backup) {
      resolution = 'backup'
    } else {
      resolution = 'backup'
    }

    if (dryRun) {
      logger.info(`[DRY RUN] Would ${resolution} existing ${conflict.type}: ${target}`)
    } else {
      if (resolution === 'backup') {
        await createBackup(target)
      }

      // Remove existing file/symlink
      try {
        const type = getPathType(target)
        if (type === 'directory') {
          await rm(target, { recursive: true })
        } else {
          await unlink(target)
        }
      } catch (error) {
        logger.error(`Failed to remove existing ${conflict.type}: ${target}`)
        return false
      }
    }
  }

  // Create parent directories if needed
  if (link.createDirs) {
    if (dryRun) {
      logger.info(`[DRY RUN] Would create parent directories for: ${target}`)
    } else {
      await ensureParentDir(target)
    }
  }

  // Create the symlink
  if (dryRun) {
    logger.info(`[DRY RUN] Would create symlink: ${target} -> ${source}`)
    return true
  }

  try {
    const type = isDirectory(source) ? 'dir' : 'file'
    await symlink(source, target, type)

    // Calculate checksum and add to state
    const checksum = await calculateChecksum(source)
    await addSymlinkToState(target, source, checksum)

    if (!silent) {
      logger.success(`Created symlink: ${target} -> ${source}`)
    }
    return true
  } catch (error) {
    logger.error(`Failed to create symlink: ${target} -> ${source}`)
    logger.error(String(error))
    return false
  }
}

export async function removeSymlink(
  target: string,
  options: SymlinkOptions = {}
): Promise<boolean> {
  const { dryRun = false } = options
  const resolved = resolvePath(target, homedir())
  if (!pathExists(resolved)) {
    logger.debug(`Symlink does not exist: ${resolved}`)
    return true
  }
  const type = getPathType(resolved)
  if (type !== 'symlink' && type !== 'broken-symlink') {
    logger.error(`Path is not a symlink: ${resolved}`)
    return false
  }
  if (dryRun) {
    logger.info(`[DRY RUN] Would remove symlink: ${resolved}`)
    return true
  }
  try {
    await unlink(resolved)
    await removeSymlinkFromState(resolved)
    logger.success(`Removed symlink: ${resolved}`)
    return true
  } catch (error) {
    logger.error(`Failed to remove symlink: ${resolved}`)
    logger.error(String(error))
    return false
  }
}

export function normalizeSymlinks(symlinks: Record<string, unknown>): NormalizedSymlink[] {
  const result: NormalizedSymlink[] = []

  for (const [target, config] of Object.entries(symlinks)) {
    if (typeof config === 'string') {
      result.push({
        target,
        source: config,
        backup: true,
        force: false,
        createDirs: true,
      })
    } else if (typeof config === 'object' && config !== null && 'source' in config) {
      result.push({
        target,
        source: (config as { source: string }).source,
        backup: (config as { backup?: boolean }).backup ?? true,
        force: (config as { force?: boolean }).force ?? false,
        createDirs: (config as { createDirs?: boolean }).createDirs ?? true,
      })
    }
  }

  return result
}
