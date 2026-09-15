import { afterEach, expect, spyOn, test } from 'bun:test'
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { STARTER_CONFIG, initCommand } from '../../src/cli/commands/init'

const config = STARTER_CONFIG
const directories: string[] = []

afterEach(async () => {
  await Promise.all(directories.splice(0).map((path) => rm(path, { recursive: true, force: true })))
})

test('starter uses the published package and exported API', () => {
  expect(config).toContain("import { defineConfig } from '@g4rcez/bunsen'")
  expect(config).not.toContain("from 'bunsen'")
  expect(config).not.toContain('./dist/index.js')
  expect(config).not.toContain('karabiner(')
  expect(config).not.toContain('espanso(')
})

test('starter can be imported from inside the package', async () => {
  const directory = await mkdtemp(join(process.cwd(), '.bunsen-init-'))
  directories.push(directory)
  const path = join(directory, 'dotfiles.config.ts')
  await writeFile(path, config)

  const loaded = await import(`${path}?test=${Date.now()}`)
  expect(loaded.default).toEqual({
    symlinks: {},
    env: {
      variables: {},
      shells: ['zsh', 'bash'],
      exportFile: '~/.config/bunsen/env.sh',
    },
    hooks: expect.any(Object),
  })
})

test('init refuses to overwrite without force', async () => {
  const directory = await mkdtemp(join(process.cwd(), '.bunsen-init-'))
  directories.push(directory)
  const originalCwd = process.cwd()
  const path = join(directory, 'dotfiles.config.ts')
  await writeFile(path, 'keep me')
  const exit = spyOn(process, 'exit').mockImplementation((code) => {
    throw new Error(`exit:${code}`)
  })

  try {
    process.chdir(directory)
    await expect(initCommand({ force: false })).rejects.toThrow('exit:1')
    expect(await readFile(path, 'utf8')).toBe('keep me')
  } finally {
    process.chdir(originalCwd)
    exit.mockRestore()
  }
})

test('init overwrites when force is true', async () => {
  const directory = await mkdtemp(join(process.cwd(), '.bunsen-init-'))
  directories.push(directory)
  const originalCwd = process.cwd()
  const path = join(directory, 'dotfiles.config.ts')
  await writeFile(path, 'replace me')

  try {
    process.chdir(directory)
    await initCommand({ force: true })
    expect(await readFile(path, 'utf8')).toBe(config)
  } finally {
    process.chdir(originalCwd)
  }
})
