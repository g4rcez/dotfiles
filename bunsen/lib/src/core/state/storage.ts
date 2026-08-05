/**
 * State persistence and management
 */

import { homedir } from 'node:os'
import { resolve } from 'node:path'
import { mkdir } from 'node:fs/promises'
import { pathExists, readFile, writeFile } from '../../utils/fs.ts'
import { StateFileSchema } from '../config/schema.ts'
import type { StateFile } from '../config/types.ts'

const STATE_DIR = resolve(homedir(), '.config/bunsen')
const STATE_FILE = resolve(STATE_DIR, 'state.json')
const STATE_VERSION = '1.0.0'

/**
 * Gets the default empty state
 */
function getDefaultState(): StateFile {
  return {
    version: STATE_VERSION,
    lastApplied: new Date().toISOString(),
    symlinks: [],
  }
}

/**
 * Loads the state file
 */
export async function loadState(): Promise<StateFile> {
  await mkdir(STATE_DIR, { recursive: true })

  if (!pathExists(STATE_FILE)) {
    return getDefaultState()
  }

  try {
    const content = await readFile(STATE_FILE)
    const json = JSON.parse(content)
    const result = StateFileSchema.safeParse(json)

    if (!result.success) {
      console.warn('State file is invalid, using default state')
      return getDefaultState()
    }

    return result.data
  } catch (error) {
    console.warn('Failed to load state file, using default state')
    return getDefaultState()
  }
}

/**
 * Saves the state file
 */
export async function saveState(state: StateFile): Promise<void> {
  await mkdir(STATE_DIR, { recursive: true })
  const content = JSON.stringify(state, null, 2)
  await writeFile(STATE_FILE, content)
}

/**
 * Updates the last applied timestamp with profile info
 */
export async function updateLastApplied(profileName?: string): Promise<void> {
  const state = await loadState()
  state.lastApplied = new Date().toISOString()

  if (profileName) {
    state.activeProfile = profileName
  }

  await saveState(state)
}

/**
 * Gets the currently active profile
 */
export async function getActiveProfile(): Promise<string | undefined> {
  const state = await loadState()
  return state.activeProfile
}

/**
 * Adds a symlink to the state
 */
export async function addSymlinkToState(
  target: string,
  source: string,
  checksum: string
): Promise<void> {
  const state = await loadState()

  // Remove existing entry if present
  state.symlinks = state.symlinks.filter((s) => s.target !== target)

  // Add new entry
  state.symlinks.push({
    target,
    source,
    createdAt: new Date().toISOString(),
    checksum,
  })

  await saveState(state)
}

/**
 * Removes a symlink from the state
 */
export async function removeSymlinkFromState(target: string): Promise<void> {
  const state = await loadState()
  state.symlinks = state.symlinks.filter((s) => s.target !== target)
  await saveState(state)
}

/**
 * Gets all symlinks from state
 */
export async function getSymlinksFromState(): Promise<StateFile['symlinks']> {
  const state = await loadState()
  return state.symlinks
}

/**
 * Checks if a symlink is tracked in state
 */
export async function isSymlinkTracked(target: string): Promise<boolean> {
  const state = await loadState()
  return state.symlinks.some((s) => s.target === target)
}

/**
 * Updates env state
 */
export async function updateEnvState(exportFile: string, injectedShells: string[]): Promise<void> {
  const state = await loadState()
  state.env = {
    exportFile,
    injectedShells,
  }
  await saveState(state)
}

/**
 * Updates Karabiner state
 */
export async function updateKarabinerState(outputPath: string): Promise<void> {
  const state = await loadState()
  state.karabiner = {
    outputPath,
    lastGenerated: new Date().toISOString(),
  }
  await saveState(state)
}

/**
 * Updates Espanso state
 */
export async function updateEspansoState(outputPath: string): Promise<void> {
  const state = await loadState()
  state.espanso = {
    outputPath,
    lastGenerated: new Date().toISOString(),
  }
  await saveState(state)
}

/**
 * Updates packages state
 */
export async function updatePackagesState(
  installed: Array<{
    manager: import('../config/types.ts').PackageManager
    package: string
    installedAt: string
    version?: string
  }>
): Promise<void> {
  const state = await loadState()

  if (!state.packages) {
    state.packages = {
      installed: [],
      lastSync: new Date().toISOString(),
    }
  }

  // Merge with existing
  for (const pkg of installed) {
    // Remove old entry if exists
    state.packages.installed = state.packages.installed.filter(
      (p) => !(p.manager === pkg.manager && p.package === pkg.package)
    )

    // Add new entry
    state.packages.installed.push(pkg)
  }

  state.packages.lastSync = new Date().toISOString()

  await saveState(state)
}

/**
 * Gets packages from state
 */
export async function getPackagesFromState(): Promise<StateFile['packages']> {
  const state = await loadState()
  return state.packages
}

/**
 * Updates WhichKey state
 */
export async function updateWhichKeyState(
  type: 'espanso' | 'karabiner',
  outputPath: string
): Promise<void> {
  const state = await loadState()

  if (!state.whichKey) {
    state.whichKey = {
      lastGenerated: new Date().toISOString(),
    }
  }

  if (type === 'espanso') {
    state.whichKey.espansoPath = outputPath
  } else {
    state.whichKey.karabinerPath = outputPath
  }

  state.whichKey.lastGenerated = new Date().toISOString()
  await saveState(state)
}
