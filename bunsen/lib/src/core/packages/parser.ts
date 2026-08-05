import { homedir } from 'node:os'
import { readFile, pathExists } from '../../utils/fs.ts'
import { expandPath } from '../symlink/resolver.ts'

export async function parseBrewfile(filePath: string): Promise<string[]> {
  const expanded = expandPath(filePath, homedir())

  if (!pathExists(expanded)) {
    throw new Error(`Brewfile not found: ${expanded}`)
  }

  const content = await readFile(expanded)
  const packages: string[] = []

  // Parse lines like: brew "package-name"
  const brewRegex = /^brew\s+["']([^"']+)["']/gm
  let match

  while ((match = brewRegex.exec(content)) !== null) {
    packages.push(match[1])
  }

  return packages
}

/**
 * Parses an APT package list file (one package per line)
 */
export async function parseAptList(filePath: string): Promise<string[]> {
  const expanded = expandPath(filePath, homedir())
  if (!pathExists(expanded)) {
    throw new Error(`APT list not found: ${expanded}`)
  }

  const content = await readFile(expanded)

  return content
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith('#'))
}

/**
 * Parses a Pacman package list file (one package per line)
 */
export async function parsePacmanList(filePath: string): Promise<string[]> {
  return parseAptList(filePath) // Same format
}

/**
 * Parses a DNF package list file (one package per line)
 */
export async function parseDnfList(filePath: string): Promise<string[]> {
  return parseAptList(filePath) // Same format
}
