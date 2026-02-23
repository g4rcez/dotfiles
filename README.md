# dotfiles

> A comprehensive, configuration-as-code approach to managing development environment dotfiles with TypeScript/Deno, featuring custom keyboard shortcuts, text expansion, and automated symlink management.

![my shell](./assets/shell.png)

## Features

- 🎹 **Custom Keyboard Shortcuts** - Programmatic Karabiner Elements configuration with leader keys and modal editing
- 📝 **Text Expansion** - Espanso integration with dynamic snippets and clipboard management
- 🔗 **Automated Symlinks** - Smart dotfiles synchronization with custom Deno-based management system
- 🐚 **Enhanced Shell** - Zsh with modern plugins, fzf integration, and custom functions
- 🚀 **Modern Terminal** - Ghostty/Wezterm + Zellij/Tmux with session management and layouts
- ⚡ **Neovim IDE** - Comprehensive Lua configuration with LSP, treesitter, and custom keybindings
- 📦 **Package Management** - Automated Homebrew package installation and management
- 🎨 **Consistent Theming** - Catppuccin theme across all applications

## 🛠 Core Technologies

| Tool | Purpose | Configuration |
|------|---------|--------------|
| **Writeme** | Text editor for notes | [`writeme.dev`](https://app.writeme.dev/) |
| **Karabiner Elements** | Keyboard remapping & shortcuts | [`karabiner.config.ts`](karabiner.config.ts) |
| **Espanso** | Text expansion & snippets | [`espanso.config.ts`](espanso.config.ts) |
| **Deno** | Configuration management | [`dotfiles.config.ts`](dotfiles.config.ts) |
| **Bunsen** | Dotfiles management CLI | [`bunsen/`](bunsen/) |
| **Zsh** | Shell with plugins | [`zsh/`](zsh/) |
| **Neovim** | Text editor | [`config/nvim/`](config/nvim/) |
| **Ghostty** | Terminal emulator | [`config/ghostty/`](config/ghostty/) |
| **Wezterm** | Alternative terminal | [`config/wezterm/`](config/wezterm/) |
| **Tmux** | Terminal multiplexer | [`config/tmux/`](config/tmux/) |
| **Zellij** | Modern terminal multiplexer | [`config/zellij/`](config/zellij/) |

## What Gets Configured

### Keyboard Shortcuts (Karabiner)

The configuration creates a powerful modal system with Caps Lock as the hyper key:

- **Hyper + hjkl** - Vim-style navigation arrows
- **Hyper + Return** - Tmux leader key bindings
- **Hyper + w** - Window management (Aerospace)
- **Hyper + s** - System controls (brightness, volume)
- **Hyper + v** - Vim mode for system-wide navigation
- **Hyper + r** - Raycast shortcuts
- **Hyper + b** - Browser profile switching

### Text Expansion (Espanso)

Trigger: `;` prefix

- **Social**: `;git`, `;blog`, `;linkedin` - Personal links
- **Utilities**: `;uuid`, `;pass[length]`, `;cpf`, `;cnpj` - Generators
- **Colors**: `;hex`, `;rgb`, `;hsl` - Color conversions
- **Dates**: `;date`, `;time`, `;now` - Date/time insertion
- **Emojis**: `;eyes`, `;s2`, `;blz` - Quick emoji access

### 🐚 Shell Environment

**Zsh Configuration** with:
- **Oh My Zsh** framework with znap plugin manager
- **Starship** prompt with git integration and Catppuccin theme
- **FZF** for fuzzy finding with custom bindings
- **Zoxide** for smart directory jumping (`z` command)
- **Mise** for runtime version management (Node.js, Bun, Deno, .NET)
- **Atuin** for command history synchronization across machines
- **Direnv** for per-directory environment variables

**Plugins Loaded**:
- auto-notify - Desktop notifications for long-running commands
- autopair - Auto-close brackets and quotes
- forgit - Interactive git operations with fzf
- autosuggestions - Fish-like suggestions
- completions - Additional completion definitions
- history-search - Multi-line history search
- syntax-highlighting - Fish-like syntax highlighting

### ⚡ Terminal Setup

- **Ghostty** - Fast, feature-rich terminal emulator (primary)
- **Wezterm** - GPU-accelerated terminal with Lua config
- **Tmux** - Traditional terminal multiplexer with custom session management
- **Zellij** - Modern Rust-based terminal multiplexer
- **Integrated file manager** - Yazi with Catppuccin theme

### 📦 Development Tools

**Installed via Homebrew** (99 packages):

**Languages & Runtimes**:
- Rust (rust, rustup, rustp)
- Go
- Zig
- Node.js/Bun/Deno (via mise)
- .NET 10.0

**CLI Development Tools**:
- neovim - Modern Vim
- lazygit, lazydocker - TUI for git/docker
- gh - GitHub CLI
- act - Run GitHub Actions locally
- ast-grep - Structural code search
- semgrep - Static analysis
- gitleaks, ripsecrets - Secret scanning
- tokei - Code statistics

**Terminal Utilities**:
- bat - `cat` with syntax highlighting
- lsd - Modern `ls` replacement
- fd - Modern `find` replacement
- ripgrep - Fast text search
- fzf - Fuzzy finder
- delta, difftastic - Enhanced diff viewers
- bottom, htop - System monitors
- ncdu - Disk usage analyzer
- yazi - Terminal file manager

**Database & API Tools**:
- pgcli, litecli - Database CLIs with auto-completion
- posting - API client
- harlequin - SQL IDE

**Media & Files**:
- ffmpeg, imagemagick - Media processing
- exiftool - Metadata editor
- yt-dlp - Video downloader
- pandoc - Document converter

**Applications** (casks):
- Aerospace - Tiling window manager
- Karabiner Elements - Keyboard customization
- Espanso - Text expander
- Raycast - Spotlight replacement
- Obsidian - Note-taking
- Flameshot - Screenshot tool
- KeyCastr - Keystroke visualizer
- MonitorControl - External display brightness

## Directory Structure

```
dotfiles/
├── bin/                    # Custom scripts and utilities (40+)
├── config/                 # Application configurations
│   ├── nvim/              # Neovim configuration (see config/nvim/README.md)
│   ├── ghostty/           # Ghostty terminal config
│   ├── wezterm/           # Wezterm terminal config
│   ├── zellij/            # Zellij terminal multiplexer
│   ├── tmux/              # Tmux configuration
│   ├── aerospace/         # Window manager config
│   ├── yazi/              # File manager config
│   ├── lazygit/           # Git TUI config
│   ├── starship.toml      # Prompt configuration
│   ├── bat/               # Bat pager config
│   ├── lsd/               # LSD ls replacement config
│   ├── mise/              # Runtime version manager
│   ├── harlequin.toml     # SQL IDE config
│   └── ...
├── zsh/                   # Shell configuration
│   ├── zshrc              # Main zsh initialization
│   ├── alias.sh           # Command aliases (80+)
│   ├── exports.sh         # Environment variables
│   ├── git.sh             # Git functions
│   ├── fzf.sh             # FZF configuration
│   ├── node.sh            # Node.js aliases
│   ├── zellij.sh          # Zellij shortcuts
│   ├── history.sh         # History settings
│   └── ...
├── git/                   # Git configuration
│   └── gitconfig          # Git config with delta, GPG signing
├── bunsen/                # Custom configuration system
├── dotfiles.config.ts     # Main Deno configuration manager
├── karabiner.config.ts    # Keyboard shortcuts definition
├── espanso.config.ts      # Text expansion rules
├── Brewfile               # Homebrew packages (99 packages)
├── install                # Installation script
├── .tool-versions         # Mise version pinning
├── .editorconfig          # Editor standards
└── .czrc                  # Commitizen config
```

## Configuration Management

This dotfiles system uses a custom TypeScript-based configuration management built on Deno and the `@g4rcez/bunsen` library:

### Installation

```bash
# Clone the repository
git clone https://github.com/g4rcez/dotfiles $HOME/dotfiles
cd $HOME/dotfiles

# Run installation script
bash install
```

**What the install script does**:
1. Creates necessary directories (`~/.config`, `~/.tmp`, `~/tools`)
2. Symlinks zshrc to `~/.zshrc`
3. Installs mise if not present
4. Installs Bun and Node.js via mise
5. Runs `bunsen apply` to set up all configurations

### Commands

```bash
# Apply all configurations
bunsen apply

# Check configuration status
bunsen status
```

### Symlink Management

The system automatically creates symlinks from `~/dotfiles/config/*` to `~/.config/*` for:

- aerospace, alacritty, atuin, bat, btop, carapace, flameshot
- ghostty, harlequin, htop, karabiner, kitty, lazygit, lsd
- mise, nvim, starship.toml, tmux, vivid, wezterm, yazi, zellij
- and 20+ more applications

Additional symlinks:
- `~/.gitconfig` → `dotfiles/git/gitconfig`
- `~/.editorconfig` → `dotfiles/.editorconfig`
- `~/.zshrc` → `dotfiles/zsh/zshrc`

### Plugin System

The system supports custom plugins for:

- **Espanso** - Dynamic snippet generation from TypeScript
- **Karabiner** - Programmatic shortcut creation with TypeScript DSL
- **VSCode** - Extension and settings management

Example plugin configuration in `dotfiles.config.ts`:

```typescript
plugins: [
  espansoPlugin(EspansoRules),
  vscodePlugin({ path: "vscode", extensionsFile: "vscode/extensions.txt" }),
  karabinerPlugin({
    rules: KarabinerConfig.map,
    whichKey: KarabinerConfig.whichKey,
    configFile: "karabiner/karabiner.json"
  }),
]
```

## 🎨 Theming

Consistent **Catppuccin Mocha** theme across:
- Terminal (Ghostty, Wezterm, Alacritty, Kitty)
- Shell (Zsh syntax highlighting, Starship prompt)
- Editor (Neovim)
- File manager (Yazi)
- Directory listings (LSD)
- Git diff viewer (Delta)
- Bottom system monitor

**Color Palette**:
- Background: `#1e1e2e`
- Foreground: `#cdd6f4`
- Accents: Red `#f38ba8`, Green `#a6e3a1`, Blue `#89b4fa`, Yellow `#f9e2af`

## 🛠 Custom Scripts

Located in [`bin/`](bin/) - 40+ utilities:

**Git & Repository Management**:
- `worktree` - Git worktree manager with auto-cd on creation
- `git-branch.sh`, `git-fzf-preview.sh` - Enhanced git operations
- `gh-fzf`, `fzf-git` - GitHub CLI and git with fzf integration
- `release-cli` - Release management tool

**Session Management**:
- `tmux-fzf-session`, `tmux-fzf-windows` - Tmux with fzf
- `zellij-sessionx*` - Zellij session management suite (create, kill, rename, preview)

**System Utilities**:
- `clear-notifications`, `osx-close-notifications` - macOS notification management
- `listening` - Show processes listening on ports
- `notes` - Quick note-taking
- `rfv` - Fuzzy file/directory viewer

**Development Tools**:
- `json-inspect` - JSON analysis
- `relative-time-commit` - Show relative commit times
- `fishfy-path` - Convert paths to fish shell format
- `github-icon` - GitHub icon generator

## Applications Configured

### Development
- **Neovim** - Primary editor with LSP for TypeScript, Rust, Lua, Docker, YAML, JSON, HTML, CSS, Tailwind, Bash
- **VSCode** - Secondary editor with synchronized extensions
- **Git** - Enhanced with delta diff viewer, GPG signing, GitHub CLI integration, custom aliases

### Terminal
- **Ghostty** - Primary terminal emulator
- **Wezterm** - Alternative GPU-accelerated terminal
- **Tmux** - Traditional terminal multiplexer with custom keybindings
- **Zellij** - Modern alternative to tmux
- **Starship** - Cross-shell prompt with git integration

### Productivity
- **Karabiner Elements** - Advanced keyboard customization with modal system
- **Espanso** - Universal text expander with custom scripts
- **Aerospace** - Tiling window manager for macOS
- **Raycast** - Spotlight replacement with custom extensions
- **Obsidian** - Note-taking and knowledge management

### System Tools
- **Yazi** - Terminal file manager with preview
- **Lazygit** - Terminal UI for git operations
- **Lazydocker** - Terminal UI for Docker
- **Atuin** - Shell history sync across machines
- **Flameshot** - Screenshot tool with annotation

## 🔧 Customization

### Adding Keyboard Shortcuts

Edit [`karabiner.config.ts`](karabiner.config.ts):

```typescript
const modKeys = karabiner.createHyperSubLayers({
  // Add new shortcut
  n: { to: [{ key_code: "page_down" }], description: "Page down" },
});
```

**Karabiner Modes**:
- `single` - Press prefix + key once
- `hold` - Hold prefix until notification, then press key (can repeat keys)

**Inspiration**: Based on [mxstbr's karabiner config](https://github.com/mxstbr/karabiner)

Recommended videos:
- [Max Stoiber Owns His Workflow with Raycast](https://www.youtube.com/watch?v=m5MDv9qwhU8)
- [How I Programed the Most Productive MacOS Keyboard Setup Ever](https://www.youtube.com/watch?v=j4b_uQX3Vu0)

### Adding Text Expansion

Edit [`espanso.config.ts`](espanso.config.ts):

```typescript
espanso.insert("mykey", "My expanded text", "Description"),
```

Example espanso config:

```yaml
matches:
    - trigger: ";cnpj"
      replace: "{{cnpj}}"
      vars:
          - name: "cnpj"
            type: "shell"
            params:
                shell: "bash"
                cmd: "deno ~/dotfiles/espanso/cnpj"

    - trigger: ";date"
      replace: "{{date}}"
      vars:
          - name: "date"
            type: "date"
            params:
                format: "%d/%m/%Y"
```

### Adding Shell Aliases

Edit files in [`zsh/`](zsh/):
- `alias.sh` - Command aliases (80+ defined)
- `exports.sh` - Environment variables
- `git.sh` - Git functions
- `fzf.sh` - FZF bindings

Example aliases:
```bash
alias ll="ls -l"
alias cat="bat -p --pager cat"
alias dotfiles="cd $HOME/dotfiles"
alias vim="nvim"
```

### Modifying Neovim

See [`config/nvim/README.md`](config/nvim/README.md) for detailed Neovim configuration documentation.

## Git Configuration

**Features** (from `git/gitconfig`):
- **Delta** as pager with Catppuccin theme
- **GPG signing** with SSH format
- **GitHub CLI** for credentials
- **Auto-rebase** on pull
- **Custom aliases**: `lg` (log graph), `s` (status), `shame` (blame), `bye` (delete branch)

**Commit Message Convention**:
- Uses Commitizen with conventional-changelog format
- Configured in `.czrc`

## Requirements

- **Zsh** >= v4
- **Git** >= v2
- **Deno** >= 2.1.0
- **Mise** for runtime management
- **macOS** (primary target, some Linux support via scripts)

## My Keyboard

![my keyboard](./assets/keyboard.jpg)

Custom mechanical keyboard optimized for the Karabiner configuration with Caps Lock as hyper key.

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Neovim](https://neovim.io/) - Modern Vim
- [Catppuccin](https://catppuccin.com/) - Soothing pastel theme
- [Karabiner Elements](https://karabiner-elements.pqrs.org/) - Keyboard customization
- [Espanso](https://espanso.org/) - Text expander
- [Starship](https://starship.rs/) - Cross-shell prompt
- [@g4rcez/bunsen](https://github.com/g4rcez/bunsen) - Configuration management library

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `bunsen sync`
5. Submit a pull request

Personal dotfiles configuration provided as-is for reference and inspiration.
