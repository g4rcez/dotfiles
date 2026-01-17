# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration built on lazy.nvim with a focus on modern LSP integration, completion, and productivity features for full-stack development (TypeScript/JavaScript, Lua, Rust, C#, Docker, etc.).

## Code Formatting

Format Lua code using stylua with the following settings (defined in `.stylua.toml`):
- Column width: 160
- Indent: 4 spaces
- Quote style: auto-prefer double quotes
- Call parentheses: none
- Line endings: Unix

```bash
stylua .
```

## Architecture

### Initialization Flow

The configuration loads in this order:
1. `init.lua` - Entry point that enables vim.loader and loads core modules
2. `lua/config/options.lua` - Global vim options and settings
3. `lua/config/lazy.lua` - Lazy.nvim package manager bootstrap
4. `lua/config/autocmds.lua` - Autocommands for various events
5. `lua/config/lsp.lua` - LSP server configurations using new vim.lsp.config API
6. `lua/config/keymaps.lua` - Global keymaps using custom binding helper
7. `lazy.setup()` - Loads all plugins from `lua/plugins/`

### Key Architectural Patterns

**LSP Configuration**: This config uses Neovim's new built-in LSP configuration pattern (`vim.lsp.config` and `vim.lsp.enable`) rather than lspconfig for base server setup. The configuration is split between:
- `lua/config/lsp.lua` - Server-specific configs (capabilities, settings, filetypes)
- `lua/plugins/lspconfig.lua` - LspAttach autocommands, keymaps, and Mason integration

**Dual LSP Strategy for TypeScript/Deno**: The config intelligently switches between `vtsls` (for Node.js projects with package.json) and `denols` (for Deno projects with deno.json) using an LspAttach autocommand in `lua/config/autocmds.lua:97-109`.

**Keymap System**: Uses a custom keymap helper in `lua/config/keymaps.lua` that provides mode-specific binding functions (`bind.normal`, `bind.visual`, `bind.insert`, etc.) with consistent default options.

**Plugin Organization**: Plugins are modular and organized by function in `lua/plugins/`:
- `blinkcmp.lua` - Completion engine (blink.cmp) with LSP, snippets, and various sources
- `lspconfig.lua` - LSP attach handlers and Mason integration
- `snacks.nvim` - Multi-purpose plugin providing picker (file/grep), terminal, git integration, notifications
- `format.lua` - Formatting with null-ls (active) and conform.nvim (disabled)
- `treesitter.lua` - Syntax highlighting and parsing
- `ui.lua` - UI components (heirline statusline, catppuccin theme, noice)
- `git.lua` - Git integration (gitsigns)
- `code.lua` - Code editing helpers (autopairs, todo-comments, emmet, etc.)

### Important Conventions

**Leader Key**: Space (`<leader>` is mapped to ` `)

**Common Keybind Prefixes**:
- `<leader>f*` - File/find operations (Snacks picker)
- `<leader>s*` - Search operations (grep, lines, symbols)
- `<leader>g*` - Git operations
- `<leader>b*` - Buffer operations
- `<leader>c*` - Code actions (rename, format, organize imports)
- `<leader>h*` - Git hunk operations (gitsigns)
- `<leader>t*` - Toggle operations
- `gr*` - LSP goto operations (grn=rename, gra=code action)
- `g*` - LSP navigation (gd=definition, gr=references, gI=implementation)

**File Navigation**: Uses Snacks picker (not Telescope) - `<leader><space>` for files, `<leader>fg` for grep

**Completion**: Uses blink.cmp with multiple sources (LSP, snippets, path, buffer, git, dadbod, conventional commits for git commits)

## LSP Servers

The following LSP servers are configured and should be installed:

```bash
# JavaScript/TypeScript ecosystem
npm i -g vscode-langservers-extracted  # html, cssls, json
npm i -g @vtsls/language-server         # vtsls (TypeScript)
npm i -g tailwindcss-language-server
npm i -g css-variables-language-server
npm i -g bash-language-server
npm i -g dockerfile-language-server-nodejs
npm install @microsoft/compose-language-service

# Deno (alternative to vtsls)
# Install from https://deno.land

# Docker
go install github.com/docker/docker-language-server/cmd/docker-language-server@latest

# Lua
# lua-language-server (install via Mason or package manager)

# Rust
# rust-analyzer (install via rustup)

# Linters
npm i -g oxlint
```

Mason is configured for automatic LSP installation but manual installation commands are noted in `lua/config/lsp.lua` comments.

## Formatters and Linters

null-ls is configured with the following tools (ensure they're installed):
- stylua (Lua formatting)
- prettier (JS/TS/JSON/etc formatting)
- rustywind (Tailwind class sorting)
- hadolint (Dockerfile linting)
- yamllint (YAML linting)
- stylelint (CSS/SCSS linting)
- dotenv_linter (.env file linting)
- codespell (spell checking)

## Key Differences from Standard LazyVim

1. Uses Snacks picker instead of Telescope for fuzzy finding
2. Uses blink.cmp instead of nvim-cmp for completion
3. Uses heirline for statusline instead of lualine
4. Custom LSP configuration using vim.lsp.config/enable pattern
5. null-ls enabled (conform.nvim disabled)
6. Custom keybind helper function instead of direct vim.keymap.set
7. Includes specialized plugins like nvim-emmet, template-string, highlight-colors for web development

## Working with this Configuration

When modifying plugins:
- Add new plugins as returns in `lua/plugins/*.lua` files
- Plugin files should return tables of lazy.nvim plugin specs
- Use lazy-loading with `event`, `cmd`, `ft`, or `keys` when possible
- LSP server configs go in `lua/config/lsp.lua` using vim.lsp.config()

When adding keymaps:
- Global keymaps go in `lua/config/keymaps.lua` using the bind helper
- Plugin-specific keymaps should use the `keys` field in plugin specs
- Follow the existing prefix conventions for consistency

When changing options:
- Vim options go in `lua/config/options.lua`
- Use `vim.opt` for list/map options, `vim.o` for simple options
- Set `vim.g` for global variables
