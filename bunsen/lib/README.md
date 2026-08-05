# Bunsen

> **BUN**dle **SE**ttings **N**ow - Like Dr. Bunsen Honeydew from the Muppets, this tool brings scientific precision to your dotfiles management!
>
> And yes, it's powered by [Bun](https://bun.sh) - because when you're naming a tool after a Muppet scientist, you might as well run it on the fastest runtime that shares part of his name!

A NixOS flake-inspired dotfiles manager built with TypeScript. Manage your entire development environment with a single declarative configuration file.

## Features

- **Declarative Configuration** - Define your entire dotfiles setup in a single `dotfiles.config.ts` file
- **Symlink Management** - GNU stow-like functionality with conflict detection, backup, and state tracking
- **Package Management** - Unified package installation across Homebrew, APT, Pacman, and DNF
- **Karabiner Integration** - Generate Karabiner keyboard configurations with TypeScript (including advanced features like layers and hyper keys)
- **Window Manager Support** - Built-in integrations for AeroSpace and Rectangle window managers
- **Espanso Integration** - Create Espanso text expansion configs declaratively
- **Environment Variables** - Manage env vars and inject them into shell configs (zsh, bash, fish)
- **Type-Safe** - Full TypeScript support with autocomplete and validation
- **Native TypeScript** - Uses Bun's native TypeScript support (no build step required)
- **Idempotent** - Safe to run multiple times without side effects
- **State Tracking** - Maintains operation history for rollback and status checking

## Requirements

- Bun v1.0.0 or higher

## Installation

```bash
bun install -g @g4rcez/bunsen
```

Or use locally in your dotfiles repository:

```bash
bun install @g4rcez/bunsen
```

## Quick Start

### 1. Initialize Configuration

```bash
bunsen init
```

This creates a `dotfiles.config.ts` file in your current directory.

### 2. Edit Configuration

```typescript
import { defineConfig, karabiner, espanso, packages } from 'bunsen'

export default defineConfig({
  // Symlink management
  symlinks: {
    '~/.zshrc': '~/dotfiles/zsh/.zshrc',
    '~/.config/nvim': '~/dotfiles/nvim',
  },

  // Environment variables
  env: {
    variables: {
      EDITOR: 'nvim',
      PATH: ['$HOME/.local/bin', '$PATH'],
    },
    shells: ['zsh', 'bash'],
  },

  // Package management
  packages: packages({
    brew: ['git', 'neovim', 'tmux', 'fzf'],
    apt: ['git', 'neovim', 'tmux'],
  }),

  // Karabiner keyboard configuration
  karabiner: karabiner({
    profiles: [{
      name: 'Default',
      rules: [{
        description: 'Caps Lock to Escape',
        manipulators: [{
          type: 'basic',
          from: { key_code: 'caps_lock' },
          to: [{ key_code: 'escape' }],
        }],
      }],
    }],
    outputPath: '~/.config/karabiner/karabiner.json',
  }),

  // Espanso text expansion
  espanso: espanso({
    matches: [
      { trigger: ':shrug', replace: '¯\\_(ツ)_/¯' },
      { trigger: ':email', replace: 'your.email@example.com' },
    ],
    outputPath: '~/.config/espanso/match/base.yml',
  }),
})
```

### 3. Apply Configuration

```bash
# Preview changes
bunsen apply --dry-run

# Apply all configurations
bunsen apply

# Apply specific parts
bunsen apply --symlinks-only
bunsen apply --packages-only
bunsen apply --env-only
```

### 4. Check Status

```bash
bunsen status
```

## Commands

### `bunsen init`

Creates a new `dotfiles.config.ts` template with examples.

**Options:**
- `-f, --force` - Overwrite existing configuration file

### `bunsen validate`

Validates your configuration file against the schema.

**Options:**
- `-c, --config <path>` - Path to config file (auto-discovered if not specified)

### `bunsen apply`

Applies your dotfiles configuration (symlinks, packages, env vars, etc.).

**Options:**
- `-c, --config <path>` - Path to config file
- `--dry-run` - Preview changes without applying them
- `-f, --force` - Skip confirmation prompts and overwrite existing files
- `--symlinks-only` - Only apply symlinks
- `--packages-only` - Only install packages
- `--env-only` - Only apply environment variables
- `--karabiner-only` - Only apply Karabiner configuration
- `--espanso-only` - Only apply Espanso configuration
- `-v, --verbose` - Enable verbose logging

### `bunsen status`

Shows the current state of your dotfiles (symlinks, env injection status, etc.).

## Configuration Guide

### Symlinks

**Simple mapping:**
```typescript
symlinks: {
  '~/.zshrc': '~/dotfiles/zsh/.zshrc',
  '~/.config/nvim': '~/dotfiles/nvim',
}
```

**Advanced options:**
```typescript
symlinks: {
  '~/.ssh/config': {
    source: '~/dotfiles/ssh/config',
    backup: true,        // Create backup if file exists
    force: false,        // Require confirmation before overwriting
    createDirs: true,    // Create parent directories
  },
}
```

### Environment Variables

```typescript
env: {
  variables: {
    EDITOR: 'nvim',
    VISUAL: 'nvim',
    // Control PATH order with $PATH token
    PATH: ['$HOME/.local/bin', '$PATH', '$HOME/.cargo/bin'],
    NODE_ENV: 'development',
  },
  shells: ['zsh', 'bash', 'fish'],
  exportFile: '~/.config/bunsen/env.sh',
}
```

The generated file is automatically sourced in your shell configs using markers:
```bash
# BEGIN BUNSEN
source ~/.config/bunsen/env.sh
# END BUNSEN
```

### Package Management

Bunsen supports multiple package managers with a unified interface:

```typescript
packages: packages({
  // Homebrew (macOS)
  brew: {
    packages: ['git', 'neovim', 'tmux', 'fzf', 'ripgrep'],
    // Or import from Brewfile
    import: '~/dotfiles/Brewfile',
  },

  // APT (Debian/Ubuntu)
  apt: ['git', 'curl', 'build-essential', 'neovim'],

  // Pacman (Arch Linux)
  pacman: ['git', 'neovim', 'tmux'],

  // DNF (Fedora/RHEL)
  dnf: ['git', 'neovim', 'tmux'],

  // Import packages from a file
  // pacman: importFrom('~/dotfiles/packages.txt'),

  // Auto-sudo for system package managers
  autoSudo: false, // Set to true to automatically use sudo for apt/pacman/dnf
})
```

### Karabiner Configuration

**Basic example:**
```typescript
karabiner: karabiner({
  profiles: [{
    name: 'Default',
    rules: [{
      description: 'Caps Lock to Escape when pressed alone, Hyper when held',
      manipulators: [{
        type: 'basic',
        from: { key_code: 'caps_lock' },
        to: [{
          key_code: 'left_shift',
          modifiers: ['left_control', 'left_option', 'left_command'],
        }],
        to_if_alone: [{ key_code: 'escape' }],
      }],
    }],
  }],
  outputPath: '~/.config/karabiner/karabiner.json',
})
```

### Window Manager Integration

**AeroSpace:**
```typescript
import { aerospace } from 'bunsen'

karabiner: karabiner({
  windowManager: aerospace({
    modifier: 'hyper', // Use Hyper key for all shortcuts
    // Custom key mappings
    focus: { h: 'left', j: 'down', k: 'up', l: 'right' },
    move: { h: 'left', j: 'down', k: 'up', l: 'right' },
  }),
  // ... other karabiner config
})
```

**Rectangle:**
```typescript
import { rectangle } from 'bunsen'

karabiner: karabiner({
  windowManager: rectangle({
    modifier: 'ctrl+cmd',
    actions: ['maximize', 'left-half', 'right-half', 'center'],
  }),
  // ... other karabiner config
})
```

### Espanso Text Expansion

```typescript
espanso: espanso({
  matches: [
    // Simple replacement
    { trigger: ':shrug', replace: '¯\\_(ツ)_/¯' },
    { trigger: ':email', replace: 'your.email@example.com' },

    // With variables
    {
      trigger: ':date',
      replace: '{{date}}',
      vars: [{
        name: 'date',
        type: 'date',
        params: { format: '%Y-%m-%d' },
      }],
    },

    // Shell command output
    {
      trigger: ':git',
      replace: '{{output}}',
      vars: [{
        name: 'output',
        type: 'shell',
        params: { cmd: 'git branch --show-current' },
      }],
    },
  ],
  outputPath: '~/.config/espanso/match/base.yml',
})
```

Or use helper functions:

```typescript
import { espanso, textReplacement, dateReplacement, shellReplacement } from 'bunsen'

espanso: espanso({
  matches: [
    textReplacement(':shrug', '¯\\_(ツ)_/¯'),
    dateReplacement(':date', '%Y-%m-%d'),
    shellReplacement(':branch', 'git branch --show-current'),
  ],
  outputPath: '~/.config/espanso/match/base.yml',
})
```

### Lifecycle Hooks

Execute custom logic before and after applying your configuration:

```typescript
hooks: {
  beforeApply: async () => {
    console.log('Running pre-apply checks...')
    // Run custom validation, backup operations, etc.
  },
  afterApply: async () => {
    console.log('Done! Remember to restart your shell.')
    // Reload services, send notifications, etc.
  },
}
```

## How It Works

### Configuration Loading

Bunsen searches for `dotfiles.config.ts` in:
1. Current working directory
2. Path specified via `--config` flag
3. `~/.config/bunsen/dotfiles.config.ts`
4. `~/dotfiles/dotfiles.config.ts`
5. `~/.dotfiles/dotfiles.config.ts`

The configuration is loaded using Bun's native TypeScript support (no transpilation!) and validated against Zod schemas.

### State Tracking

All operations are tracked in `~/.config/bunsen/state.json`. This enables:
- **Status checking** - See what Bunsen has created
- **Conflict detection** - Prevent accidental overwrites
- **Idempotent operations** - Safe to run `bunsen apply` multiple times
- **Future rollback** - (Coming soon) Undo all Bunsen changes

### Conflict Resolution

When a symlink target already exists:
1. **Backup (default)** - Creates `.backup.{timestamp}` file
2. **Overwrite** - Removes existing file (with `--force` flag)
3. **Skip** - Leaves existing file unchanged (interactive mode)

### Path Resolution

All paths are resolved securely:
1. Expand `~` to `$HOME`
2. Expand environment variables (`$HOME`, `$USER`, etc.)
3. Resolve to absolute paths
4. Validate no directory traversal (`..`) attacks

## Examples

See the [examples](./examples) directory for complete configuration examples:
- `dotfiles.config.ts` - Full-featured example with all features
- `karabiner.config.ts` - Karabiner-specific examples
- `espanso-config/` - Espanso configuration examples
- `window-managers.config.ts` - AeroSpace and Rectangle examples

## Development

Bunsen runs TypeScript directly using Bun's native support - no build step required!

```bash
# Clone the repository
git clone https://github.com/g4rcez/bunsen.git
cd bunsen

# Install dependencies
bun install

# Run CLI from TypeScript source
bun run bunsen -- --help
bun run bunsen -- init
bun run bunsen -- apply --dry-run

# Or use the wrapper script
./bunsen --help

# Run tests
bun test

# Run tests with coverage
bun test --coverage

# Type check
bun run typecheck

# Format code
bun run format
```

## Architecture

```
CLI Commands (src/cli/commands/)
    ↓
Config Loader (src/core/config/loader.ts)
    ↓
Zod Validation (src/core/config/schema.ts)
    ↓
┌─────────────────┬──────────────────┬──────────────────┬──────────────────┐
│                 │                  │                  │                  │
Symlink Manager   Generator: Env     Generator: Packages  Generator: Karabiner  Generator: Espanso
    ↓                 ↓                   ↓                    ↓                    ↓
Path Resolver     Shell Integration  Package Installers   karabiner.ts lib      YAML serialization
    ↓
State Tracker (src/core/state/)
```

**Key principles:**
- **Bun Native TypeScript** - No transpilation, instant startup
- **Dynamic Imports** - User configs loaded at runtime
- **Zod Validation** - Type-safe configuration with helpful errors
- **Idempotent Operations** - Safe to run multiple times
- **Security First** - Path validation, no directory traversal

See [CLAUDE.md](./CLAUDE.md) for detailed architecture documentation.

## Roadmap

### Planned Features

#### VS Code Integration
- [ ] **VS Code Extensions Sync** - Declaratively manage VS Code extensions
  ```typescript
  vscode: {
    extensions: [
      'vscodevim.vim',
      'esbenp.prettier-vscode',
      'bradlc.vscode-tailwindcss',
    ],
    autoInstall: true,
  }
  ```
- [ ] **VS Code Settings Link** - Symlink VS Code settings from dotfiles
  ```typescript
  vscode: {
    settingsPath: '~/dotfiles/vscode/settings.json',
    keybindingsPath: '~/dotfiles/vscode/keybindings.json',
    snippetsDir: '~/dotfiles/vscode/snippets',
  }
  ```

#### Other Planned Features
- [ ] **Template Support** - Use variables and templates in config files
- [ ] **Homebrew Cask Support** - Install GUI applications
- [ ] **System Preferences** - Manage macOS defaults and system settings
- [ ] **Secrets Management** - Secure handling of API keys and tokens
- [ ] **Multi-Machine Profiles** - Different configs for different machines
- [ ] **Migration Tool** - Import from existing dotfiles managers (stow, chezmoi, yadm)
- [ ] **Plugin System** - Extend Bunsen with custom generators

### Contributing

Contributions are welcome! If you'd like to work on any roadmap items or have ideas for new features, please open an issue or submit a pull request.

## Inspiration

Bunsen is inspired by:
- **NixOS** - Declarative configuration approach
- **GNU Stow** - Symlink management
- **Homebrew Bundle** - Package management
- **karabiner.ts** - TypeScript-first keyboard customization

## FAQ

**Q: Why Bun instead of Node.js?**
A: Bun's native TypeScript support means no build step, faster startup, and a better developer experience. Plus, the name synergy with Bunsen Honeydew was too good to pass up!

**Q: Can I use this with my existing dotfiles?**
A: Yes! Bunsen is designed to work alongside your existing setup. Start by symlinking a few files and gradually expand.

**Q: What happens if I delete my config file?**
A: Your symlinks and generated files remain until you explicitly remove them. Use `bunsen status` to see what Bunsen has created.

**Q: Is this cross-platform?**
A: Bunsen works on macOS and Linux. Windows support is not planned (WSL2 should work fine though).

**Q: How is this different from [chezmoi/yadm/dotbot]?**
A: Bunsen is TypeScript-first with full type safety, uses Bun for instant execution, and includes specialized integrations for Karabiner and Espanso. It's designed for developers who want to write their dotfiles config in TypeScript with autocomplete and validation.

## License

MIT

## Credits

Created by [g4rcez](https://github.com/g4rcez)
