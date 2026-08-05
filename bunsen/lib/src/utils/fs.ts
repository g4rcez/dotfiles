import { promises as fs } from 'node:fs'
import { existsSync, lstatSync } from 'node:fs'
import { createHash } from 'node:crypto'
import { dirname } from 'node:path'

/**
 * Checks if a path exists
 */
export function pathExists(path: string): boolean {
  return existsSync(path)
}

/**
 * Checks if a path is a file
 */
export function isFile(path: string): boolean {
  try {
    return existsSync(path) && lstatSync(path).isFile()
  } catch {
    return false
  }
}

/**
 * Checks if a path is a directory
 */
export function isDirectory(path: string): boolean {
  try {
    return existsSync(path) && lstatSync(path).isDirectory()
  } catch {
    return false
  }
}

/**
 * Checks if a path is a symlink
 */
export function isSymlink(path: string): boolean {
  try {
    return existsSync(path) && lstatSync(path).isSymbolicLink()
  } catch {
    return false
  }
}

/**
 * Checks if a symlink is broken
 */
export async function isBrokenSymlink(path: string): Promise<boolean> {
  try {
    if (!isSymlink(path)) return false
    await fs.access(path)
    return false
  } catch {
    return true
  }
}

/**
 * Gets the type of a path
 */
export function getPathType(path: string): 'file' | 'directory' | 'symlink' | 'broken-symlink' | 'none' {
  if (!pathExists(path)) {
    // Check if it's a broken symlink
    try {
      lstatSync(path)
      return 'broken-symlink'
    } catch {
      return 'none'
    }
  }

  if (isSymlink(path)) return 'symlink'
  if (isDirectory(path)) return 'directory'
  if (isFile(path)) return 'file'
  return 'none'
}

/**
 * Ensures parent directories exist
 */
export async function ensureParentDir(path: string): Promise<void> {
  const parent = dirname(path)
  await fs.mkdir(parent, { recursive: true })
}

/**
 * Calculates SHA256 checksum of a file
 */
export async function calculateChecksum(filePath: string): Promise<string> {
  try {
    const content = await fs.readFile(filePath)
    return createHash('sha256').update(content).digest('hex')
  } catch {
    return ''
  }
}

/**
 * Reads a file as text
 */
export async function readFile(path: string): Promise<string> {
  return fs.readFile(path, 'utf-8')
}

/**
 * Writes a file with content
 */
export async function writeFile(path: string, content: string): Promise<void> {
  await ensureParentDir(path)
  await fs.writeFile(path, content, 'utf-8')
}

/**
 * Reads the target of a symlink
 */
export async function readSymlink(path: string): Promise<string> {
  return fs.readlink(path)
}
