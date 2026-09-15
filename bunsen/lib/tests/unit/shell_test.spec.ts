import { expect, test } from 'bun:test'
import { buildShellConfigContent } from '../../src/utils/shell'

const home = '/Users/testuser'
const exportFile = `${home}/.config/bunsen/env.sh`

test('buildShellConfigContent uses $HOME and adds one integration block', () => {
  const content = buildShellConfigContent('# existing content', exportFile, home)

  expect(content).toContain('# existing content')
  expect(content).toContain(
    '[ -z "$BUNSEN_ENV_LOADED" ] && [ -f "$HOME/.config/bunsen/env.sh" ] && source "$HOME/.config/bunsen/env.sh"'
  )
  expect(content.match(/# BEGIN BUNSEN/g)).toHaveLength(1)
  expect(content.match(/# END BUNSEN/g)).toHaveLength(1)
})

test('buildShellConfigContent replaces an existing integration block', () => {
  const existing = `before\n# BEGIN BUNSEN\nold\n# END BUNSEN\nafter\n`
  const content = buildShellConfigContent(existing, exportFile, home)

  expect(content).toContain('before')
  expect(content).toContain('after')
  expect(content).not.toContain('\nold\n')
  expect(content.match(/# BEGIN BUNSEN/g)).toHaveLength(1)
})
