import { homedir } from 'node:os'
import { dirname, isAbsolute, resolve } from 'node:path'
import { calculateChecksum, isSymlink, pathExists, readSymlink } from '../../utils/fs.ts'
import { resolvePath } from '../symlink/resolver.ts'
import { getSymlinksFromState, loadState } from './storage.ts'
import type { StateFile } from '../config/types.ts'

export interface SymlinkStatus {
  target: string
  source: string
  status: 'ok' | 'missing' | 'modified' | 'not-symlink' | 'wrong-target'
  currentChecksum?: string
  expectedChecksum: string
}

export function resolveSymlinkDestination(target: string, destination: string): string {
  return isAbsolute(destination) ? resolve(destination) : resolve(dirname(target), destination)
}

export async function getSymlinkStatus(
  link: StateFile['symlinks'][number],
  home: string
): Promise<SymlinkStatus> {
  const target = resolvePath(link.target, home)
  const source = resolvePath(link.source, home)
  const base = { target: link.target, source: link.source, expectedChecksum: link.checksum }

  if (!pathExists(target)) return { ...base, status: 'missing' }
  if (!isSymlink(target)) return { ...base, status: 'not-symlink' }

  const destination = resolveSymlinkDestination(target, await readSymlink(target))
  if (destination !== resolve(source)) return { ...base, status: 'wrong-target' }
  if (!pathExists(source)) return { ...base, status: 'missing' }

  const currentChecksum = await calculateChecksum(source)
  if (currentChecksum !== link.checksum && link.checksum !== '') {
    return { ...base, status: 'modified', currentChecksum }
  }

  return { ...base, status: 'ok', currentChecksum }
}

/**
 * Gets the status of all tracked symlinks
 */
export async function getSymlinkStatuses(): Promise<SymlinkStatus[]> {
  const trackedSymlinks = await getSymlinksFromState()
  const home = homedir()
  return Promise.all(trackedSymlinks.map((link) => getSymlinkStatus(link, home)))
}

/**
 * Gets overall status summary
 */
export async function getStatusSummary() {
  const statuses = await getSymlinkStatuses()
  const state = await loadState()

  return {
    total: statuses.length,
    ok: statuses.filter((s) => s.status === 'ok').length,
    missing: statuses.filter((s) => s.status === 'missing').length,
    modified: statuses.filter((s) => s.status === 'modified').length,
    notSymlink: statuses.filter((s) => s.status === 'not-symlink').length,
    wrongTarget: statuses.filter((s) => s.status === 'wrong-target').length,
    lastApplied: state.lastApplied,
    hasEnv: !!state.env,
    hasKarabiner: !!state.karabiner,
    hasEspanso: !!state.espanso,
  }
}
