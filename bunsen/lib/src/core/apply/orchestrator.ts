import type { DotfilesConfig, ProfileContext } from '../config/types.ts'
import { generateEnvConfig } from '../generators/env.ts'
import { generateEspansoConfig } from '../generators/espanso.ts'
import { generateKarabinerConfig } from '../generators/karabiner.ts'
import { generatePackagesConfig } from '../generators/packages.ts'
import { createSymlink, normalizeSymlinks } from '../symlink/manager.ts'
import { updateLastApplied } from '../state/storage.ts'

export interface ApplySelection {
  symlinksOnly?: boolean
  envOnly?: boolean
  karabinerOnly?: boolean
  espansoOnly?: boolean
  packagesOnly?: boolean
}

export interface ApplyConfigurationOptions extends ApplySelection {
  config: DotfilesConfig
  context: ProfileContext
  dryRun?: boolean
  force?: boolean
}

export interface ApplySummary {
  symlinks: { completed: number; total: number; links: Array<{ target: string; source: string }> }
}

export interface ApplyDependencies {
  generateEnvConfig: typeof generateEnvConfig
  generateEspansoConfig: typeof generateEspansoConfig
  generateKarabinerConfig: typeof generateKarabinerConfig
  generatePackagesConfig: typeof generatePackagesConfig
  createSymlink: typeof createSymlink
  normalizeSymlinks: typeof normalizeSymlinks
  updateLastApplied: typeof updateLastApplied
}

const defaultDependencies: ApplyDependencies = {
  generateEnvConfig,
  generateEspansoConfig,
  generateKarabinerConfig,
  generatePackagesConfig,
  createSymlink,
  normalizeSymlinks,
  updateLastApplied,
}

const sectionFlags: Array<keyof ApplySelection> = [
  'symlinksOnly',
  'envOnly',
  'karabinerOnly',
  'espansoOnly',
  'packagesOnly',
]

function sectionEnabled(selection: ApplySelection, section: keyof ApplySelection): boolean {
  return !sectionFlags.some((flag) => selection[flag]) || selection[section] === true
}

export async function applyConfiguration(
  options: ApplyConfigurationOptions,
  dependencies: ApplyDependencies = defaultDependencies
): Promise<ApplySummary> {
  const { config, context, dryRun = false, force = false } = options
  const summary: ApplySummary = { symlinks: { completed: 0, total: 0, links: [] } }

  if (!dryRun) await config.hooks?.beforeApply?.()

  if (sectionEnabled(options, 'packagesOnly') && config.packages) {
    await dependencies.generatePackagesConfig(config.packages, { dryRun })
  }

  if (sectionEnabled(options, 'symlinksOnly') && config.symlinks) {
    const links = dependencies.normalizeSymlinks(config.symlinks)
    summary.symlinks.total = links.length
    for (const link of links) {
      const success = await dependencies.createSymlink(link, { dryRun, force, silent: true })
      if (!success) throw new Error(`Failed to apply symlink: ${link.target}`)
      summary.symlinks.completed += 1
      summary.symlinks.links.push({ target: link.target, source: link.source })
    }
  }

  if (sectionEnabled(options, 'envOnly') && (config.env || context.profile)) {
    await dependencies.generateEnvConfig(
      config.env ?? { shells: ['zsh', 'bash'], variables: {} },
      { dryRun, profileName: context.profile || undefined }
    )
  }

  if (sectionEnabled(options, 'karabinerOnly') && config.karabiner) {
    await dependencies.generateKarabinerConfig(config.karabiner, { dryRun })
  }

  if (sectionEnabled(options, 'espansoOnly') && config.espanso) {
    await dependencies.generateEspansoConfig(config.espanso, { dryRun })
  }

  if (!dryRun) {
    if (context.profile) await dependencies.updateLastApplied(context.profile)
    await config.hooks?.afterApply?.()
  }

  return summary
}
