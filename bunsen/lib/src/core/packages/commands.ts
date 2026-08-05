/**
 * Package manager command definitions and behaviors
 */

import type { PackageManager } from '../config/types.ts'

export interface PackageManagerCommands {
  /** Check if a package is installed */
  check: (pkg: string) => string[]

  /** Install a package */
  install: (pkg: string) => string[]

  /** Whether this PM requires sudo */
  requiresSudo: boolean

  /** Parse installed check output */
  parseCheckOutput: (stdout: string, pkg: string) => boolean
}

export const PACKAGE_MANAGER_COMMANDS: Record<PackageManager, PackageManagerCommands> = {
  brew: {
    check: (pkg) => ['brew', 'list', '--formula', pkg],
    install: (pkg) => ['brew', 'install', pkg],
    requiresSudo: false,
    parseCheckOutput: (stdout) => stdout.trim().length > 0,
  },

  apt: {
    check: (pkg) => ['dpkg', '-l', pkg],
    install: (pkg) => ['apt-get', 'install', '-y', pkg],
    requiresSudo: true,
    parseCheckOutput: (stdout, pkg) => {
      // dpkg -l shows "ii" at the start of line if installed
      return stdout.includes(`ii  ${pkg}`)
    },
  },

  pacman: {
    check: (pkg) => ['pacman', '-Q', pkg],
    install: (pkg) => ['pacman', '-S', '--noconfirm', pkg],
    requiresSudo: true,
    parseCheckOutput: (stdout) => stdout.trim().length > 0,
  },

  dnf: {
    check: (pkg) => ['dnf', 'list', 'installed', pkg],
    install: (pkg) => ['dnf', 'install', '-y', pkg],
    requiresSudo: true,
    parseCheckOutput: (stdout) => {
      return stdout.toLowerCase().includes('installed packages')
    },
  },
}
