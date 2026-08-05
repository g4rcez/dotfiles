import { rename } from 'fs/promises'
import { getPathType, readSymlink } from '../../utils/fs.ts'
import { logger } from '../../utils/logger.ts'

export interface ConflictInfo {
  exists: boolean
  type: 'file' | 'directory' | 'symlink' | 'broken-symlink' | 'none'
  isCorrectSymlink: boolean
  currentTarget?: string
}

/**
 * Checks for conflicts at the target path
 */
export async function checkConflict(target: string, expectedSource: string): Promise<ConflictInfo> {
  const type = getPathType(target)

  if (type === 'none') {
    return {
      exists: false,
      type: 'none',
      isCorrectSymlink: false,
    }
  }

  // If it's a symlink, check if it points to the expected source
  if (type === 'symlink') {
    try {
      const currentTarget = await readSymlink(target)
      const isCorrect = currentTarget === expectedSource

      return {
        exists: true,
        type: 'symlink',
        isCorrectSymlink: isCorrect,
        currentTarget,
      }
    } catch {
      return {
        exists: true,
        type: 'symlink',
        isCorrectSymlink: false,
      }
    }
  }

  return {
    exists: true,
    type,
    isCorrectSymlink: false,
  }
}

/**
 * Creates a backup of a file/directory
 */
export async function createBackup(path: string): Promise<string> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
  const backupPath = `${path}.backup.${timestamp}`

  try {
    await rename(path, backupPath)
    logger.success(`Created backup: ${backupPath}`)
    return backupPath
  } catch (error) {
    throw new Error(`Failed to create backup of ${path}: ${error}`)
  }
}

export type ConflictResolution = 'backup' | 'overwrite' | 'skip'

/**
 * Resolves a conflict based on user preferences
 */
export async function resolveConflict(
  target: string,
  resolution: ConflictResolution
): Promise<boolean> {
  if (resolution === 'skip') {
    logger.warn(`Skipping ${target}`)
    return false
  }

  if (resolution === 'backup') {
    await createBackup(target)
    return true
  }

  if (resolution === 'overwrite') {
    // The caller will handle removing the existing file/symlink
    return true
  }

  return false
}
