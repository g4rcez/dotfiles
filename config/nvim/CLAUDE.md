# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a LazyVim-based Neovim configuration with extensive customizations. The configuration is built on top of LazyVim and uses lazy.nvim for plugin management.

## Architecture

### Core Structure

- `init.lua`: Entry point that enables vim.loader and loads the config
- `lua/config/`: Core configuration files
  - `lazy.lua`: Plugin manager setup and LazyVim extras configuration
  - `options.lua`: Vim options and global settings
  - `keymaps.lua`: Central keymap orchestration
  - `autocmds.lua`: Autocommands (currently minimal)
  - `mappings/`: Modular keymap definitions organized by functionality
- `lua/plugins/`: Plugin-specific configurations and overrides

### Keymap System

The configuration uses a custom keymap binding system defined in `lua/config/mappings/keybind.lua`. This creates a wrapper around vim.keymap.set that integrates with which-key.

Keymap modules are organized by domain:
- `defaults.lua`: Core vim keybindings and movement
- `window-mode.lua`: Window management with timeout-based modes
- `multicursor-nvim.lua`: Multi-cursor operations
- `code.lua`: Code-related actions
- `bookmarks.lua`: Bookmark management
- `buffers.lua`: Buffer operations
- `switch.lua`: Toggle/switch functionality

Each module exports a `setup(bind)` function that receives the binding utility.

### Plugin Organization

Plugins are configured in separate files under `lua/plugins/`:
- `overwrite.lua`: Overrides LazyVim defaults (mason, treesitter)
- `blink-cmp.lua`: Completion configuration with blink.cmp
- `dotnet.lua`: .NET development with easy-dotnet.nvim
- `snacks.lua`: Extensive Snacks.nvim configuration (picker, terminal, etc.)
- `git.lua`, `sql.lua`, `tests.lua`, etc.: Language/feature-specific configs

### LazyVim Extras Integration

The configuration imports numerous LazyVim extras (see `lua/config/lazy.lua:20-42`):
- AI: sidekick
- Coding: blink, neogen
- DAP: core debugging
- Languages: docker, dotnet, git, json, markdown, rust, sql, tailwind, toml, typescript, yaml
- Utilities: dot, mini-hipatterns, rest
- Testing: core
- VSCode integration

### Environment Configuration

The configuration modifies PATH to include mise shims (`lua/config/options.lua:2`), assuming mise (formerly rtx) is used for runtime management.

## Key Settings

- Leader key: Space
- Auto-format: Disabled by default (`vim.g.autoformat = false`)
- Completion: blink.cmp (not the LazyVim default)
- Picker: Snacks picker (extensive customization with telescope-like layout)
- Terminal: Snacks terminal
- File explorer: Snacks explorer
- Clipboard: Uses system clipboard unless in SSH session
- Folding: UFO integration with custom fold keybindings

## Working with This Configuration

### Adding Plugins

Create a new file in `lua/plugins/` that returns a lazy.nvim plugin spec table. The plugin will be automatically loaded.

### Modifying Keybindings

1. Identify the appropriate module in `lua/config/mappings/`
2. Use the `bind` utility passed to `setup()`:
   - `bind.normal(from, to, opts)` for normal mode
   - `bind.visual(from, to, opts)` for visual mode
   - `bind.insert(from, to, opts)` for insert mode
   - `bind.nx(from, to, opts)` for normal + visual
3. Always include `opts.desc` for which-key integration

### Overriding LazyVim Defaults

Add overrides to `lua/plugins/overwrite.lua` or create a plugin spec with the same plugin name and `opts` table to merge.

### .NET Development

The configuration includes easy-dotnet.nvim with:
- Custom terminal function for running dotnet commands in splits
- Secrets management via `:Secrets` command
- Keybinding: `<leader>cD` to run dotnet project
- Project creation with "sln" prefix
- Auto-bootstrap namespace (block-scoped by default)

### Testing

Neotest is configured with the plenary adapter for testing Neovim plugins.

### Completion Sources

Blink.cmp is configured with these sources (in order):
1. fuzzy-path (triggered by `@` in markdown, json, git commits)
2. lsp
3. path
4. snippets
5. html-css (for web file types)
6. buffer

### Snacks.nvim

Heavily customized for:
- File picking with fuzzy matching and frecency
- Git operations (branches, log, status, diff, stash)
- LSP navigation (definitions, references, implementations)
- Zen mode and window zooming
- Scratch buffers
- Lazygit integration

## Important Paths

- Config: `~/.config/nvim` (or stdpath('config'))
- Data: `~/.local/share/nvim` (lazy.nvim installed here)
- User secrets (.NET): `~/.microsoft/usersecrets/` (macOS/Linux)
