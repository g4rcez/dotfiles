import { expect, test } from 'bun:test'
import { buildInstallCommand } from '../../src/core/packages/installer'

const apt = ['apt-get', 'install', '-y', 'git']

test('autoSudo prepends sudo for a non-root privileged manager', () => {
  expect(
    buildInstallCommand({ command: apt, requiresSudo: true, autoSudo: true, isRoot: false })
  ).toEqual(['sudo', ...apt])
})

test('autoSudo remains opt-in', () => {
  expect(
    buildInstallCommand({ command: apt, requiresSudo: true, autoSudo: false, isRoot: false })
  ).toEqual(apt)
})

test('root and non-privileged managers never get sudo', () => {
  expect(
    buildInstallCommand({ command: apt, requiresSudo: true, autoSudo: true, isRoot: true })
  ).toEqual(apt)
  expect(
    buildInstallCommand({
      command: ['brew', 'install', 'git'],
      requiresSudo: false,
      autoSudo: true,
      isRoot: false,
    })
  ).toEqual(['brew', 'install', 'git'])
})
