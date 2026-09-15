import { afterEach, expect, test } from 'bun:test'
import { mkdir, mkdtemp, rm, symlink, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { getSymlinkStatus, resolveSymlinkDestination } from '../../src/core/state/tracker'

const directories: string[] = []

afterEach(async () => {
  await Promise.all(directories.splice(0).map((path) => rm(path, { recursive: true, force: true })))
})

test('resolves relative symlink contents from the link parent', () => {
  expect(resolveSymlinkDestination('/home/user/.config/tool', '../dotfiles/tool')).toBe(
    '/home/user/dotfiles/tool'
  )
})

test('reports a relative link to the expected source as ok', async () => {
  const home = await mkdtemp(join(tmpdir(), 'bunsen-status-'))
  directories.push(home)
  await mkdir(join(home, '.config'), { recursive: true })
  await mkdir(join(home, 'dotfiles'), { recursive: true })
  await writeFile(join(home, 'dotfiles', 'tool'), 'content')
  await symlink('../dotfiles/tool', join(home, '.config', 'tool'))

  const status = await getSymlinkStatus(
    {
      target: '~/.config/tool',
      source: '~/dotfiles/tool',
      createdAt: new Date(0).toISOString(),
      checksum: '',
    },
    home
  )
  expect(status.status).toBe('ok')
})

test('reports a redirected link as wrong-target', async () => {
  const home = await mkdtemp(join(tmpdir(), 'bunsen-status-'))
  directories.push(home)
  await mkdir(join(home, '.config'), { recursive: true })
  await mkdir(join(home, 'dotfiles'), { recursive: true })
  await writeFile(join(home, 'dotfiles', 'expected'), 'expected')
  await writeFile(join(home, 'dotfiles', 'other'), 'other')
  await symlink('../dotfiles/other', join(home, '.config', 'tool'))

  const status = await getSymlinkStatus(
    {
      target: '~/.config/tool',
      source: '~/dotfiles/expected',
      createdAt: new Date(0).toISOString(),
      checksum: '',
    },
    home
  )
  expect(status.status).toBe('wrong-target')
})

test('reports a regular file as not-symlink', async () => {
  const home = await mkdtemp(join(tmpdir(), 'bunsen-status-'))
  directories.push(home)
  await mkdir(join(home, '.config'), { recursive: true })
  await mkdir(join(home, 'dotfiles'), { recursive: true })
  await writeFile(join(home, '.config', 'tool'), 'regular')
  await writeFile(join(home, 'dotfiles', 'tool'), 'source')

  const status = await getSymlinkStatus(
    {
      target: '~/.config/tool',
      source: '~/dotfiles/tool',
      createdAt: new Date(0).toISOString(),
      checksum: '',
    },
    home
  )
  expect(status.status).toBe('not-symlink')
})
