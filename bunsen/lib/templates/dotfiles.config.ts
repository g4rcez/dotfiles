import { defineConfig, karabiner, espanso } from 'bunsen'

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
    shells: ['zsh'],
    exportFile: '~/dotfiles/zsh/env.zsh',
    variables: {
      EDITOR: 'nvim',
      VISUAL: 'nvim',
      PATH: ['$HOME/.local/bin', '$PATH'],
    },
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
  //     { trigger: ':shrug', replace: '¯\\_(ツ)_/¯' },
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
