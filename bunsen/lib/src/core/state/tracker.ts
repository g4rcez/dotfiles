import { homedir } from 'node:os'
import { calculateChecksum, isSymlink, pathExists } from '../../utils/fs.ts'
import { resolvePath } from '../symlink/resolver.ts'
import { getSymlinksFromState, loadState } from './storage.ts'

export interface SymlinkStatus {
  target: string
  source: string
  status: 'ok' | 'missing' | 'modified' | 'not-symlink' | 'wrong-target'
  currentChecksum?: string
  expectedChecksum: string
}

/**
 * Gets the status of all tracked symlinks
 */
export async function getSymlinkStatuses(): Promise<SymlinkStatus[]> {
  const trackedSymlinks = await getSymlinksFromState()
  const statuses: SymlinkStatus[] = []
  const home = homedir()

  for (const link of trackedSymlinks) {
    const target = resolvePath(link.target, home)
    const source = resolvePath(link.source, home)

    // Check if symlink exists
    if (!pathExists(target)) {
      statuses.push({
        target: link.target,
        source: link.source,
        status: 'missing',
        expectedChecksum: link.checksum,
      })
      continue
    }

    // Check if it's a symlink
    if (!isSymlink(target)) {
      statuses.push({
        target: link.target,
        source: link.source,
        status: 'not-symlink',
        expectedChecksum: link.checksum,
      })
      continue
    }

    // Check if source still exists and calculate checksum
    if (!pathExists(source)) {
      statuses.push({
        target: link.target,
        source: link.source,
        status: 'missing',
        expectedChecksum: link.checksum,
      })
      continue
    }

    const currentChecksum = await calculateChecksum(source)

    // Check if source has been modified
    if (currentChecksum !== link.checksum && link.checksum !== '') {
      statuses.push({
        target: link.target,
        source: link.source,
        status: 'modified',
        currentChecksum,
        expectedChecksum: link.checksum,
      })
      continue
    }

    statuses.push({
      target: link.target,
      source: link.source,
      status: 'ok',
      currentChecksum,
      expectedChecksum: link.checksum,
    })
  }

  return statuses
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
    lastApplied: state.lastApplied,
    hasEnv: !!state.env,
    hasKarabiner: !!state.karabiner,
    hasEspanso: !!state.espanso,
  }
}
