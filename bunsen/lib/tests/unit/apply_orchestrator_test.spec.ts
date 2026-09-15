import { expect, test } from 'bun:test'
import {
  applyConfiguration,
  type ApplyDependencies,
  type ApplyConfigurationOptions,
} from '../../src/core/apply/orchestrator'

function setup(events: string[], symlinkSuccess = true): ApplyDependencies {
  return {
    generatePackagesConfig: async () => { events.push('packages') },
    normalizeSymlinks: () => [{ target: '/target', source: '/source', backup: true, force: false, createDirs: true }],
    createSymlink: async () => { events.push('symlink'); return symlinkSuccess },
    generateEnvConfig: async () => { events.push('env') },
    generateKarabinerConfig: async () => { events.push('karabiner') },
    generateEspansoConfig: async () => { events.push('espanso') },
    updateLastApplied: async () => { events.push('state') },
  }
}

function options(events: string[]): ApplyConfigurationOptions {
  return {
    config: {
      packages: { brew: ['git'] },
      symlinks: { '/target': '/source' },
      env: { variables: {}, shells: ['zsh'] },
      hooks: {
        beforeApply: () => { events.push('before') },
        afterApply: () => { events.push('after') },
      },
    },
    context: { profile: 'work', exists: true, source: 'cli' },
  }
}

test('orchestrator owns mutation, state, and hook order', async () => {
  const events: string[] = []
  const result = await applyConfiguration(options(events), setup(events))
  expect(events).toEqual(['before', 'packages', 'symlink', 'env', 'state', 'after'])
  expect(result.symlinks).toEqual({ completed: 1, total: 1, links: [{ target: '/target', source: '/source' }] })
})

test('a section filter runs only that mutation between hooks', async () => {
  const events: string[] = []
  await applyConfiguration({ ...options(events), envOnly: true }, setup(events))
  expect(events).toEqual(['before', 'env', 'state', 'after'])
})
