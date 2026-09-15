import { resolve } from 'node:path'
import { pathExists, writeFile } from '../../utils/fs.ts'
import { logger } from '../../utils/logger.ts'

export const STARTER_CONFIG = `import { defineConfig } from '@g4rcez/bunsen'

export default defineConfig({
  // Symlink management
  symlinks: {
    // Simple mapping: target -> source
    // '~/.zshrc': '~/dotfiles/zsh/.zshrc',
    // '~/.config/nvim': '~/dotfiles/nvim',

    // Advanced with options
    // '~/.ssh/config': {
    //   source: '~/dotfiles/ssh/config',
    //   backup: true,
    //   force: false,
    // },
  },

  // Environment variables
  env: {
    variables: {
      // EDITOR: 'nvim',
      // VISUAL: 'nvim',
      // PATH: ['$HOME/.local/bin', '$PATH'],
    },
    shells: ['zsh', 'bash'],
    exportFile: '~/.config/bunsen/env.sh',
  },

  // Lifecycle hooks
  hooks: {
    beforeApply: async () => {
      console.log('Running pre-apply checks...')
    },
    afterApply: async () => {
      console.log('Configuration applied successfully!')
    },
  },
})
`

export async function initCommand(options: { force?: boolean }) {
  const configPath = resolve(process.cwd(), 'dotfiles.config.ts')
  if (pathExists(configPath) && !options.force) {
    logger.error('dotfiles.config.ts already exists')
    logger.info('Use --force to overwrite')
    process.exit(1)
  }

  await writeFile(configPath, STARTER_CONFIG)
  logger.success('Created dotfiles.config.ts')
  logger.info('Edit the file to configure your dotfiles')
  logger.info('Run "bunsen apply" when ready')
}
