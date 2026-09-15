import { expect, test } from 'bun:test'
import { applyConfiguration, type ApplyDependencies } from '../../src/core/apply/orchestrator'

function dependencies(events: string[], createResult: boolean): ApplyDependencies {
  return {
    generatePackagesConfig: async () => {},
    normalizeSymlinks: () => [
      { target: '/first', source: '/source/first', backup: true, force: false, createDirs: true },
      { target: '/second', source: '/source/second', backup: true, force: false, createDirs: true },
    ],
    createSymlink: async (link) => {
      events.push(link.target)
      return link.target === '/first' ? createResult : true
    },
    generateEnvConfig: async () => { events.push('env') },
    generateKarabinerConfig: async () => {},
    generateEspansoConfig: async () => {},
    updateLastApplied: async () => { events.push('state') },
  }
}

test('a failed symlink stops later mutations, state, and after hook', async () => {
  const events: string[] = []
  await expect(
    applyConfiguration(
      {
        config: {
          symlinks: { '/first': '/source/first', '/second': '/source/second' },
          env: { variables: {}, shells: ['zsh'] },
          hooks: { afterApply: () => { events.push('after') } },
        },
        context: { profile: 'work', exists: true, source: 'cli' },
      },
      dependencies(events, false)
    )
  ).rejects.toThrow('Failed to apply symlink: /first')
  expect(events).toEqual(['/first'])
})

test('a generator exception propagates without recording success', async () => {
  const events: string[] = []
  const deps = dependencies(events, true)
  deps.generatePackagesConfig = async () => { throw new Error('installer failed') }

  await expect(
    applyConfiguration(
      {
        config: { packages: { brew: ['git'] }, hooks: { afterApply: () => { events.push('after') } } },
        context: { profile: 'work', exists: true, source: 'cli' },
      },
      deps
    )
  ).rejects.toThrow('installer failed')
  expect(events).toEqual([])
})
