import { expect, test } from 'bun:test'
import { resolveEnvExportFile } from '../../src/core/generators/env'

const home = '/tmp/bunsen-test-home'

test('default env file uses tilde notation and resolves inside home', () => {
  const path = resolveEnvExportFile(undefined, home)
  expect(path).toBe(`${home}/.config/bunsen/env.sh`)
  expect(path).not.toContain('$HOME')
})

test('configured tilde env file uses the same resolver', () => {
  expect(resolveEnvExportFile('~/.local/env.sh', home)).toBe(`${home}/.local/env.sh`)
})
