import type { PackageManager } from '../config/types.ts'

async function commandExists(command: string): Promise<boolean> {
  try {
    const proc = Bun.spawn(['which', command], { stdout: 'ignore', stderr: 'ignore' })
    const exitCode = await proc.exited
    return exitCode === 0
  } catch {
    return false
  }
}

export async function detectAvailableManagers(): Promise<PackageManager[]> {
  const managers: PackageManager[] = []
  if (await commandExists('brew')) managers.push('brew')
  if (await commandExists('apt-get')) managers.push('apt')
  if (await commandExists('pacman')) managers.push('pacman')
  if (await commandExists('dnf')) managers.push('dnf')
  return managers
}

/**
 * Detects the primary package manager for the current OS
 */
export async function detectPrimaryManager(): Promise<PackageManager | null> {
  const platform = process.platform

  if (platform === 'darwin') {
    return (await commandExists('brew')) ? 'brew' : null
  }

  if (platform === 'linux') {
    if (await commandExists('apt-get')) return 'apt'
    if (await commandExists('dnf')) return 'dnf'
    if (await commandExists('pacman')) return 'pacman'
  }

  return null
}
