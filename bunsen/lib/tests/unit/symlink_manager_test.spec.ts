import { afterEach, expect, mock, test } from 'bun:test'
import { mkdtemp, readFile, readlink, readdir, rm, symlink, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

mock.module('../../src/core/state/storage.ts', () => ({
  addSymlinkToState: async () => {},
  removeSymlinkFromState: async () => {},
}))

const { createSymlink } = await import('../../src/core/symlink/manager')
const directories: string[] = []

afterEach(async () => {
  await Promise.all(directories.splice(0).map((path) => rm(path, { recursive: true, force: true })))
})

test('backup mode preserves the conflict and creates the link', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'bunsen-symlink-'))
  directories.push(directory)
  const source = join(directory, 'source')
  const target = join(directory, 'target')
  await writeFile(source, 'new')
  await writeFile(target, 'old')

  const success = await createSymlink({
    source,
    target,
    backup: true,
    force: false,
    createDirs: true,
  })

  expect(success).toBe(true)
  expect(await readlink(target)).toBe(source)
  const backups = (await readdir(directory)).filter((name) => name.startsWith('target.backup.'))
  expect(backups).toHaveLength(1)
  expect(await readFile(join(directory, backups[0]), 'utf8')).toBe('old')
})

test('force overwrites without creating a backup', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'bunsen-symlink-'))
  directories.push(directory)
  const source = join(directory, 'source')
  const target = join(directory, 'target')
  await writeFile(source, 'new')
  await writeFile(target, 'old')

  expect(await createSymlink({ source, target, backup: true, force: true, createDirs: true })).toBe(
    true
  )
  expect(await readlink(target)).toBe(source)
  expect((await readdir(directory)).some((name) => name.startsWith('target.backup.'))).toBe(false)
})

test('an already correct link remains unchanged', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'bunsen-symlink-'))
  directories.push(directory)
  const source = join(directory, 'source')
  const target = join(directory, 'target')
  await writeFile(source, 'new')
  await symlink(source, target)

  expect(
    await createSymlink({ source, target, backup: true, force: false, createDirs: true })
  ).toBe(true)
  expect(await readlink(target)).toBe(source)
  expect((await readdir(directory)).some((name) => name.startsWith('target.backup.'))).toBe(false)
})

test('dry-run does not mutate a conflicting target', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'bunsen-symlink-'))
  directories.push(directory)
  const source = join(directory, 'source')
  const target = join(directory, 'target')
  await writeFile(source, 'new')
  await writeFile(target, 'old')

  expect(
    await createSymlink(
      { source, target, backup: true, force: false, createDirs: true },
      { dryRun: true }
    )
  ).toBe(true)
  expect(await readFile(target, 'utf8')).toBe('old')
})
