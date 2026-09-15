import { logger } from '../../utils/logger.ts'
import { PACKAGE_MANAGER_COMMANDS } from './commands.ts'
import type { PackageManager, PackageInstallResult } from '../config/types.ts'

interface InstallCommandOptions {
  command: string[]
  requiresSudo: boolean
  autoSudo: boolean
  isRoot: boolean
}

export function buildInstallCommand(options: InstallCommandOptions): string[] {
  const { command, requiresSudo, autoSudo, isRoot } = options
  return requiresSudo && autoSudo && !isRoot ? ['sudo', ...command] : command
}

/**
 * Checks if a package is already installed
 */
export async function isPackageInstalled(manager: PackageManager, pkg: string): Promise<boolean> {
  const commands = PACKAGE_MANAGER_COMMANDS[manager]

  try {
    const checkCmd = commands.check(pkg)
    const proc = Bun.spawn(checkCmd, { stdout: 'pipe', stderr: 'ignore' })
    const stdout = await new Response(proc.stdout).text()
    await proc.exited
    return commands.parseCheckOutput(stdout, pkg)
  } catch {
    return false
  }
}

/**
 * Installs a single package
 */
export async function installPackage(
  manager: PackageManager,
  pkg: string,
  options: { dryRun?: boolean; autoSudo?: boolean } = {}
): Promise<PackageInstallResult> {
  const { dryRun = false, autoSudo = false } = options
  const commands = PACKAGE_MANAGER_COMMANDS[manager]

  // Check if already installed
  const alreadyInstalled = await isPackageInstalled(manager, pkg)

  if (alreadyInstalled) {
    return {
      manager,
      package: pkg,
      success: true,
      alreadyInstalled: true,
    }
  }

  if (dryRun) {
    logger.info(`[DRY RUN] Would install ${pkg} via ${manager}`)
    return {
      manager,
      package: pkg,
      success: true,
      alreadyInstalled: false,
    }
  }

  const installCmd = buildInstallCommand({
    command: commands.install(pkg),
    requiresSudo: commands.requiresSudo,
    autoSudo,
    isRoot: process.getuid?.() === 0,
  })

  try {
    const proc = Bun.spawn(installCmd, {
      stdout: 'inherit', // Show output to user
      stderr: 'inherit',
      stdin: 'inherit',
    })

    const exitCode = await proc.exited

    if (exitCode !== 0) {
      throw new Error(`Command exited with code ${exitCode}`)
    }

    return {
      manager,
      package: pkg,
      success: true,
      alreadyInstalled: false,
    }
  } catch (error) {
    return {
      manager,
      package: pkg,
      success: false,
      alreadyInstalled: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    }
  }
}

/**
 * Installs multiple packages with a single manager
 */
export async function installPackages(
  manager: PackageManager,
  packages: string[],
  options: { dryRun?: boolean; autoSudo?: boolean } = {}
): Promise<PackageInstallResult[]> {
  const results: PackageInstallResult[] = []

  for (const pkg of packages) {
    const result = await installPackage(manager, pkg, options)
    results.push(result)
  }

  return results
}
