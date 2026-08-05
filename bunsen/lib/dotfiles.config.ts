import { defineConfig } from './src/api/index.ts'

/**
 * Bunsen Dotfiles Configuration
 *
 * Profiles with smart auto-selection:
 *   1. CLI parameter: bunsen apply --profile work
 *   2. Environment variable: BUNSEN_PROFILE=work
 *   3. Hostname matching: auto-selects based on hostname
 *   4. Default profile: fallback to 'default' profile
 *
 * Free-form profiles:
 *   bunsen profile my-custom-name
 *   → Uses base config + sets BUNSEN_PROFILE="my-custom-name"
 */

export default defineConfig({
  // Base config (applies to ALL profiles)
  symlinks: {
    '~/.zshrc': '~/dotfiles/zsh/.zshrc',
    '~/.config/nvim': '~/dotfiles/nvim',
  },

  env: {
    shells: ['zsh', 'bash'],
    exportFile: '~/.config/bunsen/env.sh',
    variables: {
      EDITOR: 'nvim',
      VISUAL: 'nvim',
      PAGER: 'less',
      LANG: 'en_US.UTF-8',
      RUST_BACKTRACE: '1',
    },
  },

  profiles: {
    default: {
      // Fallback profile
      symlinks: {
        '~/.gitconfig': '~/dotfiles/git/.gitconfig',
      },
    },

    work: {
      extends: 'default',
      hostname: 'work-laptop',  // Auto-select on this hostname
      env: {
        variables: {
          AWS_PROFILE: 'work',
          WORK_MODE: 'true',
        },
      },
      symlinks: {
        '~/.ssh/config': '~/dotfiles/ssh/work-config',
      },
    },

    home: {
      extends: 'default',
      hostname: ['home-desktop', 'macbook-pro'],  // Multiple hostnames
      env: {
        variables: {
          AWS_PROFILE: 'personal',
        },
      },
      symlinks: {
        '~/.ssh/config': '~/dotfiles/ssh/personal-config',
      },
    },

    minimal: {
      // No extends, standalone profile
      symlinks: {
        '~/.zshrc': '~/dotfiles/zsh/.zshrc-minimal',
      },
    },
  },

  // Global sections (apply to all profiles)
  hooks: {
    beforeApply: async () => {
      console.log('🚀 Applying dotfiles configuration...')
    },
    afterApply: async () => {
      console.log('✅ Dotfiles applied successfully!')
      console.log('📝 Remember to restart your shell or run: source ~/.zshrc')
    },
  },
})
