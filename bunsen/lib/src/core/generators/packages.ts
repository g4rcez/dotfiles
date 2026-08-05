import ora from 'ora'
import { colors } from '../../utils/colors.ts'
import { logger } from '../../utils/logger.ts'
import { detectAvailableManagers } from '../packages/detector.ts'
import { installPackages } from '../packages/installer.ts'
import { parseBrewfile, parseAptList, parsePacmanList, parseDnfList } from '../packages/parser.ts'
import { updatePackagesState } from '../state/storage.ts'
import type { PackageManagerConfig, PackageManager, PackageInstallResult } from '../config/types.ts'

async function normalizePackageList(
  manager: PackageManager,
  config: string[] | { packages?: string[]; import?: string }
): Promise<string[]> {
  if (Array.isArray(config)) {
    return config
  }
  const packages: string[] = []
  if (config.packages) {
    packages.push(...config.packages)
  }
  if (config.import) {
    try {
      let imported: string[] = []
      switch (manager) {
        case 'brew':
          imported = await parseBrewfile(config.import)
          break
        case 'apt':
          imported = await parseAptList(config.import)
          break
        case 'pacman':
          imported = await parsePacmanList(config.import)
          break
        case 'dnf':
          imported = await parseDnfList(config.import)
          break
      }
      packages.push(...imported)
    } catch (error) {
      logger.error(`Failed to import ${manager} packages: ${error}`)
    }
  }
  return [...new Set(packages)]
}

export async function generatePackagesConfig(
  config: PackageManagerConfig,
  options: { dryRun?: boolean } = {}
): Promise<void> {
  const { dryRun = false } = options
  const spinner = ora('Detecting package managers...').start()

  const available = await detectAvailableManagers()
  spinner.succeed(`Found package managers: ${available.join(', ') || 'none'}`)

  if (available.length === 0) {
    logger.warn('No supported package managers found on this system')
    return
  }

  const allResults: PackageInstallResult[] = []

  for (const manager of ['brew', 'apt', 'pacman', 'dnf'] as PackageManager[]) {
    const managerConfig = config[manager]
    if (!managerConfig) continue
    if (!available.includes(manager)) {
      logger.warn(`${manager} is configured but not available on this system`)
      continue
    }
    const packages = await normalizePackageList(manager, managerConfig)
    if (packages.length === 0) {
      logger.info(`No packages to install for ${manager}`)
      continue
    }
    spinner.start(`Installing ${packages.length} packages via ${manager}...`)
    const results = await installPackages(manager, packages, {
      dryRun,
      autoSudo: config.autoSudo,
    })
    allResults.push(...results)
    const installed = results.filter((r) => r.success && !r.alreadyInstalled).length
    const alreadyInstalled = results.filter((r) => r.alreadyInstalled).length
    const failed = results.filter((r) => !r.success).length
    if (dryRun) {
      spinner.info(`[DRY RUN] Would install ${packages.length} packages via ${manager}`)
    } else {
      const summary = [
        installed > 0 ? colors.green(`${installed} installed`) : null,
        alreadyInstalled > 0 ? colors.gray(`${alreadyInstalled} already installed`) : null,
        failed > 0 ? colors.red(`${failed} failed`) : null,
      ]
        .filter(Boolean)
        .join(', ')

      if (failed > 0) {
        spinner.warn(`${manager}: ${summary}`)
      } else {
        spinner.succeed(`${manager}: ${summary}`)
      }
    }
    results
      .filter((r) => !r.success)
      .forEach((r) => {
        logger.error(`Failed to install ${r.package}: ${r.error}`)
      })
  }

  if (!dryRun && allResults.length > 0) {
    const installed = allResults
      .filter((r) => r.success && !r.alreadyInstalled)
      .map((r) => ({
        manager: r.manager,
        package: r.package,
        installedAt: new Date().toISOString(),
      }))

    await updatePackagesState(installed)
  }
}
