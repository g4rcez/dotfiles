import { afterEach, expect, test } from 'bun:test'
import { mkdtemp, readFile, readdir, rm, stat, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { diffCommand } from '../../../src/cli/commands/diff'

const directories: string[] = []
afterEach(async () => {
  await Promise.all(directories.splice(0).map((path) => rm(path, { recursive: true, force: true })))
})

async function snapshot(directory: string) {
  const names = (await readdir(directory)).sort()
  return Promise.all(
    names.map(async (name) => {
      const path = join(directory, name)
      const metadata = await stat(path)
      return {
        name,
        mode: metadata.mode,
        content: metadata.isFile() ? await readFile(path, 'utf8') : null,
      }
    })
  )
}

test('command rejects conflicting section filters before loading configuration', async () => {
  await expect(diffCommand({ envOnly: true, packagesOnly: true })).rejects.toThrow(
    'Choose only one --*-only filter'
  )
})

test('CLI diff is read-only for a loadable config fixture', async () => {
  const directory = await mkdtemp(join(process.cwd(), '.bunsen-diff-cli-'))
  directories.push(directory)
  const configPath = join(directory, 'dotfiles.config.ts')
  const hookMarker = join(directory, 'hook-ran')
  const target = join(directory, 'target')
  await writeFile(
    configPath,
    `import { defineConfig } from '@g4rcez/bunsen'\n` +
      `export default defineConfig({\n` +
      `  symlinks: { ${JSON.stringify(target)}: ${JSON.stringify(configPath)} },\n` +
      `  hooks: { beforeApply: async () => { await Bun.write(${JSON.stringify(hookMarker)}, 'bad') } },\n` +
      `})\n`
  )
  const before = await snapshot(directory)

  const child = Bun.spawn(
    [process.execPath, 'src/cli/index.ts', 'diff', '--config', configPath, '--symlinks-only'],
    { cwd: process.cwd(), stdout: 'pipe', stderr: 'pipe' }
  )
  const [output, error, exitCode] = await Promise.all([
    new Response(child.stdout).text(),
    new Response(child.stderr).text(),
    child.exited,
  ])

  expect(exitCode, error).toBe(0)
  expect(output).toContain(target)
  expect(await snapshot(directory)).toEqual(before)
})
