import { resolve, basename } from 'node:path'
import { homedir } from 'node:os'
import { pathExists, writeFile } from '../../utils/fs.ts'
import { logger } from '../../utils/logger.ts'

function getImportStatement(): string {
  const username = basename(homedir())
  const isBunsenRepo = process.cwd().includes('bunsen') && process.cwd().includes(username)
  if (isBunsenRepo) {
    return `// Running from Bunsen repo - using local build
import { defineConfig, karabiner, espanso } from './dist/index.js'`
  }

  return `import { defineConfig, karabiner, espanso } from 'bunsen'`
}

const TEMPLATE = `${getImportStatement()}

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

  // Karabiner configuration
  // karabiner: karabiner({
  //   profiles: [{
  //     name: 'Default',
  //     rules: [{
  //       description: 'Caps Lock to Escape',
  //       manipulators: [{
  //         type: 'basic',
  //         from: { key_code: 'caps_lock' },
  //         to: [{ key_code: 'escape' }],
  //       }],
  //     }],
  //   }],
  //   outputPath: '~/.config/karabiner/karabiner.json',
  // }),

  // Espanso configuration
  // espanso: espanso({
  //   matches: [
  //     { trigger: ':shrug', replace: '¯\\\\_(ツ)_/¯' },
  //   ],
  //   outputPath: '~/.config/espanso/match/base.yml',
  // }),

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

  await writeFile(configPath, TEMPLATE)
  logger.success('Created dotfiles.config.ts')
  logger.info('Edit the file to configure your dotfiles')
  logger.info('Run "bunsen apply" when ready')
}
