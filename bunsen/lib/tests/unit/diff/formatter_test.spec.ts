import { expect, test } from 'bun:test'
import { formatDiffResult } from '../../../src/core/diff/formatter'
import type { DiffResult } from '../../../src/core/diff/types'

const empty = (): DiffResult => ({
  symlinks: [],
  env: [],
  karabiner: [],
  espanso: [],
  packages: [],
  warnings: [],
  hasChanges: false,
})
const plain = (value: string) => value.replace(/\x1b\[[0-9;]*m/g, '')

test('formatter distinguishes changes from retained stale resources', () => {
  const result = empty()
  result.hasChanges = true
  result.symlinks = [
    { section: 'symlink', changeType: 'add', path: '~/.new', newValue: '~/source' },
    { section: 'symlink', changeType: 'stale', path: '~/.old', oldValue: '~/old' },
  ]

  const output = plain(formatDiffResult(result))
  expect(output).toContain('+ ~/.new → ~/source')
  expect(output).toContain('~ ~/.old is stale and will be retained')
  expect(output).toContain('Summary: 1 change detected; 1 stale resource retained')
  expect(output).not.toContain('will be removed')
})

test('formatter includes warnings without turning them into actions', () => {
  const result = empty()
  result.warnings = ['Existing config is malformed']
  const output = plain(formatDiffResult(result))
  expect(output).toContain('No changes detected')
  expect(output).toContain('Warning: Existing config is malformed')
})
