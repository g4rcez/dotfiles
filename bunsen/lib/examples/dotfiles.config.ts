import { defineConfig, karabiner, espanso, packages, importFrom, hyperKey, mapKey } from 'lucius'

export default defineConfig({
  // Symlink management
  symlinks: {
    // Development tools
    '~/.zshrc': '~/dotfiles/zsh/.zshrc',
    '~/.config/nvim': '~/dotfiles/nvim',
    '~/.gitconfig': '~/dotfiles/git/.gitconfig',
    '~/.tmux.conf': '~/dotfiles/tmux/.tmux.conf',

    // SSH with backup
    '~/.ssh/config': {
      source: '~/dotfiles/ssh/config',
      backup: true,
      force: false,
    },

    // Applications
    '~/.config/alacritty': '~/dotfiles/alacritty',
    '~/.config/starship.toml': '~/dotfiles/starship/starship.toml',
  },

  // Environment variables
  env: {
    variables: {
      EDITOR: 'nvim',
      VISUAL: 'nvim',
      PAGER: 'less',
      LANG: 'en_US.UTF-8',
      PATH: [
        '$HOME/.local/bin',
        '$HOME/.cargo/bin',
        '$HOME/go/bin',
        '$HOME/.npm-global/bin',
        '$PATH',
      ],
      NODE_ENV: 'development',
      RUST_BACKTRACE: '1',
    },
    shells: ['zsh', 'bash'],
    exportFile: '~/.config/lucius/env.sh',
  },

  // Package management
  packages: packages({
    // Homebrew (macOS)
    brew: {
      packages: ['git', 'neovim', 'tmux', 'fzf', 'ripgrep', 'bat', 'eza', 'zoxide'],
      // Or import from a Brewfile: import: '~/dotfiles/Brewfile'
    },

    // APT (Debian/Ubuntu) - simple array
    apt: ['git', 'curl', 'build-essential', 'neovim'],

    // Pacman (Arch Linux) - import from file
    // pacman: importFrom('~/dotfiles/packages.txt'),

    // DNF (Fedora/RHEL)
    // dnf: ['git', 'neovim', 'tmux'],

    // Auto-sudo for system package managers (apt, pacman, dnf)
    autoSudo: false, // Set to true to skip sudo prompts
  }),

  // Karabiner configuration
  karabiner: karabiner({
    profiles: [
      {
        name: 'Default',
        rules: [
          {
            description: 'Caps Lock to Hyper/Escape',
            manipulators: [
              {
                type: 'basic',
                from: { key_code: 'caps_lock' },
                to: [
                  {
                    key_code: 'left_shift',
                    modifiers: ['left_control', 'left_option', 'left_command'],
                  },
                ],
                to_if_alone: [{ key_code: 'escape' }],
              },
            ],
          },
          {
            description: 'Hyper+HJKL to Arrow Keys',
            manipulators: [
              {
                type: 'basic',
                from: {
                  key_code: 'h',
                  modifiers: {
                    mandatory: ['left_shift', 'left_control', 'left_option', 'left_command'],
                  },
                },
                to: [{ key_code: 'left_arrow' }],
              },
              {
                type: 'basic',
                from: {
                  key_code: 'j',
                  modifiers: {
                    mandatory: ['left_shift', 'left_control', 'left_option', 'left_command'],
                  },
                },
                to: [{ key_code: 'down_arrow' }],
              },
              {
                type: 'basic',
                from: {
                  key_code: 'k',
                  modifiers: {
                    mandatory: ['left_shift', 'left_control', 'left_option', 'left_command'],
                  },
                },
                to: [{ key_code: 'up_arrow' }],
              },
              {
                type: 'basic',
                from: {
                  key_code: 'l',
                  modifiers: {
                    mandatory: ['left_shift', 'left_control', 'left_option', 'left_command'],
                  },
                },
                to: [{ key_code: 'right_arrow' }],
              },
            ],
          },
        ],
      },
    ],
    outputPath: '~/.config/karabiner/karabiner.json',
  }),

  // Espanso configuration
  espanso: espanso({
    matches: [
      // Emoticons
      { trigger: ':shrug', replace: '¯\\_(ツ)_/¯' },
      { trigger: ':tableflip', replace: '(╯°□°)╯︵ ┻━┻' },
      { trigger: ':lenny', replace: '( ͡° ͜ʖ ͡°)' },

      // Personal info
      { trigger: ':email', replace: 'your.email@example.com' },
      { trigger: ':gh', replace: 'https://github.com/yourusername' },

      // Date and time
      {
        trigger: ':date',
        replace: '{{date}}',
        vars: [
          {
            name: 'date',
            type: 'date',
            params: { format: '%Y-%m-%d' },
          },
        ],
      },
      {
        trigger: ':datetime',
        replace: '{{datetime}}',
        vars: [
          {
            name: 'datetime',
            type: 'date',
            params: { format: '%Y-%m-%d %H:%M:%S' },
          },
        ],
      },
      { trigger: ':log', replace: 'console.log($|$)' },
      { trigger: ':todo', replace: 'TODO: $|$' },
    ],
    outputPath: '~/.config/espanso/match/base.yml',
  }),

  // Lifecycle hooks
  hooks: {
    beforeApply: async () => {
      console.log('🚀 Starting dotfiles application...')
    },
    afterApply: async () => {
      console.log('✅ Dotfiles applied successfully!')
      console.log('📝 Remember to restart your shell or run: source ~/.zshrc')
    },
  },
})
