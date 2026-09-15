import { beforeEach, expect, mock, test } from 'bun:test'
import { applyCommand, type ApplyOptions } from '../../src/cli/commands/apply'
import type { ApplyConfigurationOptions, ApplySummary } from '../../src/core/apply/orchestrator'

let appliedOptions: ApplyConfigurationOptions | null = null

mock.module('../../src/core/config/loader.ts', () => ({
  loadConfig: async ({ profile }: { profile?: string }) => ({
    config: {},
    context: { profile: profile ?? '', exists: true, source: 'cli' },
  }),
}))

mock.module('../../src/utils/logger.ts', () => ({
  logger: { info: () => {}, warn: () => {}, error: () => {}, plain: () => {}, success: () => {} },
}))

mock.module('ora', () => () => ({
  start() { return this },
  succeed() { return this },
  fail() { return this },
  info() { return this },
  stop() { return this },
}))

const summary: ApplySummary = { symlinks: { completed: 0, total: 0, links: [] } }
const captureApply = async (options: ApplyConfigurationOptions): Promise<ApplySummary> => {
  appliedOptions = options
  return summary
}

beforeEach(() => {
  appliedOptions = null
})

test('applyCommand forwards an explicit profile to the orchestrator', async () => {
  const options: ApplyOptions = { profile: 'test-profile', dryRun: false }
  await applyCommand(options, captureApply)

  expect(appliedOptions).not.toBeNull()
  expect(appliedOptions?.context).toEqual({ profile: 'test-profile', exists: true, source: 'cli' })
})

test('applyCommand forwards an empty profile context', async () => {
  await applyCommand({ dryRun: false }, captureApply)
  expect(appliedOptions).not.toBeNull()
  expect(appliedOptions?.context).toEqual({ profile: '', exists: true, source: 'cli' })
})
