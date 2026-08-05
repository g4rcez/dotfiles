import { homedir } from 'node:os'
import { resolve } from 'node:path'
import type { DotfilesConfig } from '../config/types.js'
import { loadState } from '../state/storage.js'
import { normalizeSymlinks } from '../symlink/manager.js'
import { resolvePath } from '../symlink/resolver.js'
import { pathExists, readFile } from '../../utils/fs.ts'
import type { DiffResult, DiffOptions, DiffEntry, CurrentState, DesiredState } from './types.js'

export async function loadCurrentState(): Promise<CurrentState> {
  const state = await loadState()
  const home = homedir()

  const currentState: CurrentState = {
    symlinks: state.symlinks,
    envFile: null,
    envVariables: {},
    karabinerConfig: null,
    espansoConfig: null,
    installedPackages: {},
  }

  const envFilePath = resolve(home, '.config/bunsen/env.sh')
  if (pathExists(envFilePath)) {
    currentState.envFile = envFilePath
    try {
      const content = await readFile(envFilePath)
      const lines = content.split('\n')
      for (const line of lines) {
        const match = line.match(/^export\s+([^=]+)=(.+)$/)
        if (match) {
          const [, key, value] = match
          currentState.envVariables[key] = value.replace(/^["']|["']$/g, '')
        }
      }
    } catch {}
  }

  const karabinerPath = resolve(home, '.config/karabiner/karabiner.json')
  if (pathExists(karabinerPath)) {
    try {
      const content = await readFile(karabinerPath)
      currentState.karabinerConfig = JSON.parse(content)
    } catch {}
  }

  return currentState
}

export async function loadDesiredState(config: DotfilesConfig): Promise<DesiredState> {
  const symlinks = normalizeSymlinks(config.symlinks || {})

  const desiredState: DesiredState = {
    symlinks: {},
    envVariables: config.env?.variables || {},
    karabinerConfig: config.karabiner || null,
    espansoConfig: config.espanso || null,
    packages: {},
  }

  for (const link of symlinks) {
    desiredState.symlinks[link.target] = link.source
  }

  return desiredState
}

export function compareSymlinks(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []
  const home = homedir()

  const currentMap = new Map(
    current.symlinks.map(s => [
      resolvePath(s.target, home),
      { original: s.target, resolved: resolvePath(s.source, home), originalSource: s.source }
    ])
  )

  const desiredMap = new Map(
    Object.entries(desired.symlinks).map(([target, source]) => [
      resolvePath(target, home),
      { original: target, resolved: resolvePath(source, home), originalSource: source }
    ])
  )

  for (const [resolvedTarget, desiredInfo] of desiredMap) {
    const currentInfo = currentMap.get(resolvedTarget)
    if (!currentInfo) {
      entries.push({
        section: 'symlink',
        changeType: 'add',
        path: desiredInfo.original,
        newValue: desiredInfo.originalSource,
      })
    } else if (currentInfo.resolved !== desiredInfo.resolved) {
      entries.push({
        section: 'symlink',
        changeType: 'modify',
        path: desiredInfo.original,
        oldValue: currentInfo.originalSource,
        newValue: desiredInfo.originalSource,
      })
    }
  }

  for (const [resolvedTarget, currentInfo] of currentMap) {
    if (!desiredMap.has(resolvedTarget)) {
      entries.push({
        section: 'symlink',
        changeType: 'remove',
        path: currentInfo.original,
        oldValue: currentInfo.originalSource,
      })
    }
  }

  return entries
}

export function compareEnv(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []
  const currentVars = current.envVariables
  const desiredVars = desired.envVariables

  for (const [key, value] of Object.entries(desiredVars)) {
    const valueStr = Array.isArray(value) ? value.join(':') : String(value)
    const currentValue = currentVars[key]

    if (!currentValue) {
      entries.push({
        section: 'env',
        changeType: 'add',
        path: key,
        newValue: valueStr,
      })
    } else if (currentValue !== valueStr) {
      entries.push({
        section: 'env',
        changeType: 'modify',
        path: key,
        oldValue: currentValue,
        newValue: valueStr,
      })
    }
  }

  for (const key of Object.keys(currentVars)) {
    if (!(key in desiredVars)) {
      entries.push({
        section: 'env',
        changeType: 'remove',
        path: key,
        oldValue: currentVars[key],
      })
    }
  }

  return entries
}

export function compareKarabiner(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []

  if (!desired.karabinerConfig && !current.karabinerConfig) {
    return entries
  }

  if (desired.karabinerConfig && !current.karabinerConfig) {
    entries.push({
      section: 'karabiner',
      changeType: 'add',
      path: '~/.config/karabiner/karabiner.json',
      newValue: 'Configuration will be generated',
    })
  } else if (!desired.karabinerConfig && current.karabinerConfig) {
    entries.push({
      section: 'karabiner',
      changeType: 'remove',
      path: '~/.config/karabiner/karabiner.json',
      oldValue: 'Configuration exists',
    })
  } else if (JSON.stringify(current.karabinerConfig) !== JSON.stringify(desired.karabinerConfig)) {
    entries.push({
      section: 'karabiner',
      changeType: 'modify',
      path: '~/.config/karabiner/karabiner.json',
      oldValue: 'Current configuration',
      newValue: 'Will be regenerated',
    })
  }

  return entries
}

export function compareEspanso(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []

  if (!desired.espansoConfig && !current.espansoConfig) {
    return entries
  }

  if (desired.espansoConfig && !current.espansoConfig) {
    entries.push({
      section: 'espanso',
      changeType: 'add',
      path: 'espanso config',
      newValue: 'Configuration will be generated',
    })
  } else if (!desired.espansoConfig && current.espansoConfig) {
    entries.push({
      section: 'espanso',
      changeType: 'remove',
      path: 'espanso config',
      oldValue: 'Configuration exists',
    })
  } else if (JSON.stringify(current.espansoConfig) !== JSON.stringify(desired.espansoConfig)) {
    entries.push({
      section: 'espanso',
      changeType: 'modify',
      path: 'espanso config',
      oldValue: 'Current configuration',
      newValue: 'Will be regenerated',
    })
  }

  return entries
}

export function comparePackages(current: CurrentState, desired: DesiredState): DiffEntry[] {
  const entries: DiffEntry[] = []

  for (const [manager, packages] of Object.entries(desired.packages)) {
    const currentPackages = current.installedPackages[manager] || []

    for (const pkg of packages) {
      if (!currentPackages.includes(pkg)) {
        entries.push({
          section: 'packages',
          changeType: 'add',
          path: pkg,
          newValue: `via ${manager}`,
        })
      }
    }
  }

  return entries
}

export async function calculateDiff(
  config: DotfilesConfig,
  options: DiffOptions = {}
): Promise<DiffResult> {
  const current = await loadCurrentState()
  const desired = await loadDesiredState(config)

  const result: DiffResult = {
    symlinks: [],
    env: [],
    karabiner: [],
    espanso: [],
    packages: [],
    hasChanges: false,
  }

  if (!options.envOnly && !options.karabinerOnly && !options.espansoOnly && !options.packagesOnly) {
    result.symlinks = compareSymlinks(current, desired)
  }

  if (!options.symlinksOnly && !options.karabinerOnly && !options.espansoOnly && !options.packagesOnly) {
    result.env = compareEnv(current, desired)
  }

  if (!options.symlinksOnly && !options.envOnly && !options.espansoOnly && !options.packagesOnly) {
    result.karabiner = compareKarabiner(current, desired)
  }

  if (!options.symlinksOnly && !options.envOnly && !options.karabinerOnly && !options.packagesOnly) {
    result.espanso = compareEspanso(current, desired)
  }

  if (!options.symlinksOnly && !options.envOnly && !options.karabinerOnly && !options.espansoOnly) {
    result.packages = comparePackages(current, desired)
  }

  result.hasChanges = Object.values(result).some(v => Array.isArray(v) && v.length > 0)

  return result
}
