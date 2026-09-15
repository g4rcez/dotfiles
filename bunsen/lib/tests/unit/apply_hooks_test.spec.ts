import { expect, test } from 'bun:test'
import { applyConfiguration, type ApplyDependencies } from '../../src/core/apply/orchestrator'

function dependencies(events: string[]): ApplyDependencies {
  return {
    generatePackagesConfig: async () => { events.push('mutation') },
    normalizeSymlinks: () => [],
    createSymlink: async () => true,
    generateEnvConfig: async () => {},
    generateKarabinerConfig: async () => {},
    generateEspansoConfig: async () => {},
    updateLastApplied: async () => { events.push('state') },
  }
}

test('dry-run executes operations in preview mode but never hooks or state', async () => {
  const events: string[] = []
  await applyConfiguration(
    {
      config: {
        packages: { brew: ['git'] },
        hooks: {
          beforeApply: () => { events.push('before') },
          afterApply: () => { events.push('after') },
        },
      },
      context: { profile: 'work', exists: true, source: 'cli' },
      dryRun: true,
    },
    dependencies(events)
  )
  expect(events).toEqual(['mutation'])
})

test('a failed before hook prevents every mutation and after hook', async () => {
  const events: string[] = []
  await expect(
    applyConfiguration(
      {
        config: {
          packages: { brew: ['git'] },
          hooks: {
            beforeApply: () => { events.push('before'); throw new Error('precheck failed') },
            afterApply: () => { events.push('after') },
          },
        },
        context: { profile: 'work', exists: true, source: 'cli' },
      },
      dependencies(events)
    )
  ).rejects.toThrow('precheck failed')
  expect(events).toEqual(['before'])
})
