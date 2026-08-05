import { homedir } from 'node:os'
import { resolve } from 'node:path'
import { pathExists, readFile, writeFile } from './fs.ts'

const MARKER_BEGIN = '# BEGIN BUNSEN'
const MARKER_END = '# END BUNSEN'

/**
 * Detects the user's default shell
 */
export function detectShell(): string {
  const shell = process.env.SHELL || '/bin/bash'
  return shell
}

/**
 * Gets shell name from path
 */
export function getShellName(shellPath: string): string {
  const parts = shellPath.split('/')
  return parts[parts.length - 1] || 'bash'
}

/**
 * Gets the config file path for a shell
 */
export function getShellConfigPath(shell: 'zsh' | 'bash' | 'fish'): string {
  const home = homedir()

  switch (shell) {
    case 'zsh':
      return resolve(home, '.zshrc')
    case 'bash':
      return resolve(home, '.bashrc')
    case 'fish':
      return resolve(home, '.config/fish/config.fish')
    default:
      return resolve(home, '.bashrc')
  }
}

/**
 * Checks if shell config already has Bunsen integration
 */
export async function hasBunsenIntegration(configPath: string): Promise<boolean> {
  if (!pathExists(configPath)) {
    return false
  }

  const content = await readFile(configPath)
  return content.includes(MARKER_BEGIN) && content.includes(MARKER_END)
}

/**
 * Injects source statement into shell config
 */
export async function injectIntoShellConfig(
  configPath: string,
  exportFilePath: string
): Promise<void> {
  let content = ''

  if (pathExists(configPath)) {
    content = await readFile(configPath)

    // Remove existing Bunsen section if present
    const beginIndex = content.indexOf(MARKER_BEGIN)
    const endIndex = content.indexOf(MARKER_END)

    if (beginIndex !== -1 && endIndex !== -1) {
      const before = content.substring(0, beginIndex)
      const after = content.substring(endIndex + MARKER_END.length)
      content = before + after.trim()
    }
  }

  // Add new Bunsen section
  const home = homedir()
  const portablePath = exportFilePath.replace(home, '$HOME')
  const injection = `
${MARKER_BEGIN}
[ -z "$BUNSEN_ENV_LOADED" ] && [ -f "${portablePath}" ] && source "${portablePath}"
${MARKER_END}
`

  content = content.trim() + '\n' + injection

  await writeFile(configPath, content)
}

/**
 * Removes Bunsen integration from shell config
 */
export async function removeFromShellConfig(configPath: string): Promise<void> {
  if (!pathExists(configPath)) {
    return
  }

  let content = await readFile(configPath)

  const beginIndex = content.indexOf(MARKER_BEGIN)
  const endIndex = content.indexOf(MARKER_END)

  if (beginIndex !== -1 && endIndex !== -1) {
    const before = content.substring(0, beginIndex)
    const after = content.substring(endIndex + MARKER_END.length)
    content = (before + after).trim() + '\n'

    await writeFile(configPath, content)
  }
}
