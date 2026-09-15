import { afterEach, expect, test } from 'bun:test'
import { mkdir, mkdtemp, rm, symlink, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { Karabiner } from '../../../src/api/karabiner/karabiner'
import { calculateDiff, loadDesiredState } from '../../../src/core/diff/calculator'
import type { StateFile } from '../../../src/core/config/types'

const directories: string[] = []
afterEach(async () => {
  await Promise.all(directories.splice(0).map((path) => rm(path, { recursive: true, force: true })))
})

async function fixture(): Promise<{ home: string; state: StateFile; karabiner: Karabiner }> {
  const home = await mkdtemp(join(process.cwd(), '.bunsen-diff-'))
  directories.push(home)
  await mkdir(join(home, 'config'), { recursive: true })
  await writeFile(
    join(home, 'config', 'env.sh'),
    'export KEEP="old"\nexport REMOVE="value"\nexport BUNSEN_ENV_LOADED="true"\n'
  )
  await symlink(join(home, 'wrong-source'), join(home, 'wrong-link'))
  const karabiner = new Karabiner()
  karabiner.configPath = join(home, 'config', 'karabiner.json')
  await writeFile(karabiner.configPath, '{not json')
  const state: StateFile = {
    version: '1.0.0',
    lastApplied: '2026-01-01T00:00:00Z',
    symlinks: [
      { target: join(home, 'stale'), source: join(home, 'old'), createdAt: '', checksum: '' },
    ],
    packages: {
      installed: [{ manager: 'brew', package: 'git', installedAt: '' }],
      lastSync: '',
    },
  }
  return { home, state, karabiner }
}

test('calculator reports real drift, retained stale links, custom paths, and package additions', async () => {
  const { home, state, karabiner } = await fixture()
  const result = await calculateDiff(
    {
      symlinks: {
        [join(home, 'missing-link')]: join(home, 'source'),
        [join(home, 'wrong-link')]: join(home, 'source'),
      },
      env: {
        exportFile: join(home, 'config', 'env.sh'),
        variables: { KEEP: 'new', ADD: 'value' },
      },
      karabiner,
      packages: { brew: ['git', 'jq'] },
    },
    {},
    { home, state }
  )

  expect(result.symlinks.map((entry) => entry.changeType)).toEqual(['add', 'modify', 'stale'])
  expect(result.env.map((entry) => `${entry.path}:${entry.changeType}`).sort()).toEqual([
    'ADD:add',
    'KEEP:modify',
    'REMOVE:remove',
  ])
  expect(result.karabiner[0]?.path).toBe(karabiner.configPath)
  expect(result.packages.map((entry) => entry.path)).toEqual(['jq'])
  expect(result.warnings[0]).toContain('malformed')
})

test('each only filter excludes every other section', async () => {
  const { home, state } = await fixture()
  const result = await calculateDiff(
    {
      symlinks: { [join(home, 'missing')]: join(home, 'source') },
      env: { variables: { ADD: 'value' } },
      packages: { brew: ['jq'] },
    },
    { packagesOnly: true },
    { home, state }
  )

  expect(result.packages).toHaveLength(1)
  expect(result.symlinks).toEqual([])
  expect(result.env).toEqual([])
  expect(result.karabiner).toEqual([])
  expect(result.espanso).toEqual([])
})

test('desired state uses the same Karabiner serializer representation as apply', async () => {
  const karabiner = new Karabiner()
  const desired = await loadDesiredState({ karabiner }, {}, { home: '/tmp/home', state: null })
  expect(desired.karabinerConfig).toContain('"profiles": []')
  expect(desired.karabinerPath).toBe('/tmp/home/.config/karabiner/karabiner.json')
})
