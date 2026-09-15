import { lstat, readlink } from 'node:fs/promises'
import { homedir } from 'node:os'
import { dirname, resolve } from 'node:path'
import { parse as parseYaml } from 'yaml'
import { readFile, pathExists } from '../../utils/fs.ts'
import { serializeEspansoConfig } from '../generators/espanso.ts'
import { serializeKarabinerConfig } from '../generators/karabiner.ts'
import { normalizePackageList } from '../generators/packages.ts'
import { StateFileSchema } from '../config/schema.ts'
import type { DotfilesConfig, PackageManager, StateFile } from '../config/types.ts'
import { normalizeSymlinks } from '../symlink/manager.ts'
import { expandPath, resolvePath } from '../symlink/resolver.ts'
import type { CurrentState, DesiredState, DiffEntry, DiffOptions, DiffResult } from './types.ts'

export interface DiffRuntime {
  home?: string
  state?: StateFile | null
}

function emptyState(): StateFile {
  return { version: '1.0.0', lastApplied: '', symlinks: [] }
}

async function readState(home: string, runtime: DiffRuntime, warnings: string[]): Promise<StateFile> {
  if ('state' in runtime) return runtime.state ?? emptyState()
  const statePath = resolve(home, '.config/bunsen/state.json')
  if (!pathExists(statePath)) return emptyState()
  try {
    const parsed = StateFileSchema.safeParse(JSON.parse(await readFile(statePath)))
    if (parsed.success) return parsed.data
    warnings.push(`Cannot read Bunsen state at ${statePath}: invalid state file`)
  } catch (error) {
    warnings.push(`Cannot read Bunsen state at ${statePath}: ${String(error)}`)
  }
  return emptyState()
}

async function readGeneratedFile(
  path: string | null,
  kind: 'karabiner' | 'espanso',
  warnings: string[]
): Promise<string | null> {
  if (!path || !pathExists(path)) return null
  try {
    const content = await readFile(path)
    try {
      if (kind === 'karabiner') JSON.parse(content)
      else parseYaml(content)
    } catch (error) {
      warnings.push(`Existing ${kind} config is malformed at ${path}: ${String(error)}`)
    }
    return content
  } catch (error) {
    warnings.push(`Cannot read existing ${kind} config at ${path}: ${String(error)}`)
    return null
  }
}

export async function loadCurrentState(
  config: DotfilesConfig,
  options: DiffOptions = {},
  runtime: DiffRuntime = {}
): Promise<CurrentState> {
  const home = runtime.home ?? homedir()
  const warnings: string[] = []
  const state = await readState(home, runtime, warnings)
  const envFile =
    config.env || options.profileName
      ? expandPath(config.env?.exportFile ?? state.env?.exportFile ?? '~/.config/bunsen/env.sh', home)
      : null
  const karabinerPath = config.karabiner
    ? expandPath(config.karabiner.configPath, home)
    : state.karabiner?.outputPath ?? null
  const espansoPath = config.espanso
    ? expandPath(config.espanso.path, home)
    : state.espanso?.outputPath ?? null
  const envVariables: Record<string, string> = {}

  if (envFile && pathExists(envFile)) {
    try {
      for (const line of (await readFile(envFile)).split('\n')) {
        const match = line.match(/^export\s+([^=]+)=(.+)$/)
        if (match && match[1] !== 'BUNSEN_ENV_LOADED') {
          envVariables[match[1]] = match[2].replace(/^["']|["']$/g, '')
        }
      }
    } catch (error) {
      warnings.push(`Cannot read environment file at ${envFile}: ${String(error)}`)
    }
  }

  const installedPackages: Record<string, string[]> = {}
  for (const installed of state.packages?.installed ?? []) {
    ;(installedPackages[installed.manager] ??= []).push(installed.package)
  }

  return {
    symlinks: state.symlinks,
    envFile,
    envVariables,
    karabinerPath,
    karabinerConfig: await readGeneratedFile(karabinerPath, 'karabiner', warnings),
    espansoPath,
    espansoConfig: await readGeneratedFile(espansoPath, 'espanso', warnings),
    installedPackages,
    warnings,
  }
}

export async function loadDesiredState(
  config: DotfilesConfig,
  options: DiffOptions = {},
  runtime: DiffRuntime = {}
): Promise<DesiredState> {
  const home = runtime.home ?? homedir()
  const desired: DesiredState = {
    symlinks: {},
    envVariables: { ...(config.env?.variables ?? {}) },
    karabinerPath: config.karabiner ? expandPath(config.karabiner.configPath, home) : null,
    karabinerConfig: config.karabiner ? serializeKarabinerConfig(config.karabiner) : null,
    espansoPath: config.espanso ? expandPath(config.espanso.path, home) : null,
    espansoConfig: config.espanso ? serializeEspansoConfig(config.espanso, home) : null,
    packages: {},
  }
  if (options.profileName) desired.envVariables.BUNSEN_PROFILE = options.profileName

  for (const link of normalizeSymlinks(config.symlinks ?? {})) {
    desired.symlinks[link.target] = link.source
  }
  for (const manager of ['brew', 'apt', 'pacman', 'dnf'] as PackageManager[]) {
    const managerConfig = config.packages?.[manager]
    if (managerConfig) desired.packages[manager] = await normalizePackageList(manager, managerConfig)
  }
  return desired
}

async function inspectSymlink(target: string, home: string): Promise<string | null | 'existing-file'> {
  const resolvedTarget = resolvePath(target, home)
  try {
    const stat = await lstat(resolvedTarget)
    if (!stat.isSymbolicLink()) return 'existing-file'
    const destination = await readlink(resolvedTarget)
    return resolve(dirname(resolvedTarget), destination)
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') return null
    throw error
  }
}

export async function compareSymlinks(
  current: CurrentState,
  desired: DesiredState,
  home = homedir()
): Promise<DiffEntry[]> {
  const entries: DiffEntry[] = []
  const desiredTargets = new Set<string>()
  for (const [target, source] of Object.entries(desired.symlinks)) {
    const resolvedTarget = resolvePath(target, home)
    const resolvedSource = resolvePath(source, home)
    desiredTargets.add(resolvedTarget)
    const actual = await inspectSymlink(target, home)
    if (actual === null) {
      entries.push({ section: 'symlink', changeType: 'add', path: target, newValue: source })
    } else if (actual !== resolvedSource) {
      entries.push({
        section: 'symlink',
        changeType: 'modify',
        path: target,
        oldValue: actual,
        newValue: source,
      })
    }
  }

  for (const tracked of current.symlinks) {
    if (!desiredTargets.has(resolvePath(tracked.target, home))) {
      entries.push({
        section: 'symlink',
        changeType: 'stale',
        path: tracked.target,
        oldValue: tracked.source,
        details: { retained: true },
      })
    }
  }
  return entries
}

export function compareEnv(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []
  for (const [key, value] of Object.entries(desired.envVariables)) {
    const desiredValue = Array.isArray(value) ? value.join(':') : String(value)
    const currentValue = current.envVariables[key]
    if (currentValue === undefined) {
      entries.push({ section: 'env', changeType: 'add', path: key, newValue: desiredValue })
    } else if (currentValue !== desiredValue) {
      entries.push({
        section: 'env',
        changeType: 'modify',
        path: key,
        oldValue: currentValue,
        newValue: desiredValue,
      })
    }
  }
  for (const [key, value] of Object.entries(current.envVariables)) {
    if (!(key in desired.envVariables)) {
      entries.push({ section: 'env', changeType: 'remove', path: key, oldValue: value })
    }
  }
  return entries
}

function compareGenerated(
  section: 'karabiner' | 'espanso',
  path: string | null,
  current: string | null,
  desired: string | null
): DiffEntry[] {
  const label = section === 'karabiner' ? 'Karabiner configuration' : 'Espanso configuration'
  const outputPath = path ?? `${section} config`
  if (desired && !current) {
    return [{ section, changeType: 'add', path: outputPath, newValue: `${label} will be generated` }]
  }
  if (!desired && current) {
    return [{ section, changeType: 'stale', path: outputPath, oldValue: `${label} is retained` }]
  }
  if (desired !== current) {
    return [{ section, changeType: 'modify', path: outputPath, oldValue: 'Current content', newValue: 'Generated content' }]
  }
  return []
}

export function compareKarabiner(current: CurrentState, desired: DesiredState): DiffEntry[] {
  return compareGenerated(
    'karabiner',
    desired.karabinerPath ?? current.karabinerPath,
    current.karabinerConfig,
    desired.karabinerConfig
  )
}

export function compareEspanso(current: CurrentState, desired: DesiredState): DiffEntry[] {
  return compareGenerated(
    'espanso',
    desired.espansoPath ?? current.espansoPath,
    current.espansoConfig,
    desired.espansoConfig
  )
}

export function comparePackages(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []
  for (const [manager, packages] of Object.entries(desired.packages)) {
    const installed = current.installedPackages[manager] ?? []
    for (const packageName of packages) {
      if (!installed.includes(packageName)) {
        entries.push({
          section: 'packages',
          changeType: 'add',
          path: packageName,
          newValue: `via ${manager}`,
        })
      }
    }
  }
  return entries
}

function sectionEnabled(options: DiffOptions, section: keyof DiffOptions): boolean {
  const flags: Array<keyof DiffOptions> = [
    'symlinksOnly',
    'envOnly',
    'karabinerOnly',
    'espansoOnly',
    'packagesOnly',
  ]
  return !flags.some((flag) => options[flag] === true) || options[section] === true
}

export async function calculateDiff(
  config: DotfilesConfig,
  options: DiffOptions = {},
  runtime: DiffRuntime = {}
): Promise<DiffResult> {
  const current = await loadCurrentState(config, options, runtime)
  const desired = await loadDesiredState(config, options, runtime)
  const result: DiffResult = {
    symlinks: sectionEnabled(options, 'symlinksOnly')
      ? await compareSymlinks(current, desired, runtime.home)
      : [],
    env: sectionEnabled(options, 'envOnly') ? compareEnv(current, desired) : [],
    karabiner: sectionEnabled(options, 'karabinerOnly') ? compareKarabiner(current, desired) : [],
    espanso: sectionEnabled(options, 'espansoOnly') ? compareEspanso(current, desired) : [],
    packages: sectionEnabled(options, 'packagesOnly') ? comparePackages(current, desired) : [],
    warnings: current.warnings,
    hasChanges: false,
  }
  result.hasChanges = [
    result.symlinks,
    result.env,
    result.karabiner,
    result.espanso,
    result.packages,
  ].some((entries) => entries.length > 0)
  return result
}
