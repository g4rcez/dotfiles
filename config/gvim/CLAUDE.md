# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on kickstart.nvim, using Lazy.nvim as the plugin manager. The configuration is designed to work both in standard Neovim and VSCode Neovim extension environments.

## Architecture

The configuration follows a modular structure:

- **`init.lua`**: Entry point that detects environment (VSCode vs standard Neovim) and loads appropriate configurations
- **`lua/config/`**: Core configuration modules (options, keymaps, autocmds, etc.)
- **`lua/plugins/`**: Plugin specifications organized by functionality
- **`lua/dev/`**: Development/custom plugins and utilities

### Key Configuration Files

- `lua/config/options.lua`: Vim options and settings, including PATH setup for mise
- `lua/config/keymap.lua`: Custom keymap utility with which-key integration  
- `lua/config/autocmd.lua`: Autocommands for various behaviors (yank highlighting, LSP switching, etc.)
- `lua/config/vscode.lua`: VSCode-specific configuration

## Core Plugin Ecosystem

The configuration is built around these key plugins:

### Navigation & File Management
- **Snacks.nvim**: Primary picker/finder (replaces telescope), file explorer, and various utilities
- **Oil.nvim**: File manager with buffer-like editing (`<leader>so` for float mode)

### LSP & Development
- **nvim-lspconfig**: LSP configuration with extensive server setup
- **Mason**: Automatic tool installation (ensures formatters, linters, LSPs)
- **Blink.cmp**: Completion engine 
- **Treesitter**: Syntax highlighting and text objects

### UI & UX
- **Snacks**: Handles statuscolumn, dashboard, notifications, zen mode
- **Which-key**: Keymap discovery and organization

## Key Keybindings

### File Navigation
- `<leader><space>`: Find files (snacks.picker)
- `<leader>so`: Oil file manager (float)
- `<leader>fe`: File explorer (snacks.explorer)
- `<Tab><Tab>`: Buffer picker

### Search & Grep  
- `<leader>fg`: Live grep
- `<leader>sw`: Grep word under cursor
- `<leader>sb`: Search buffer lines

### LSP Navigation
- `gd`: Go to definition
- `gr`: Find references  
- `gI`: Go to implementation
- `gy`: Go to type definition

### Git Integration
- `<leader>gg`: Lazygit
- `<leader>gb`: Git branches
- `<leader>gl`: Git log
- `<leader>gs`: Git status

## Development Environment Features

### Language Server Management
- Automatic switching between Deno and Node.js LSP servers based on project type
- Mason ensures required tools are installed automatically
- LSP capabilities configured for advanced features (folding, completion, etc.)

### File Operations
- Oil.nvim integrates with LSP for file operations (rename detection)
- Auto-directory creation on file save
- Smart clipboard handling (SSH vs local)

### Session & Persistence  
- Automatic cursor position restoration
- Undo file persistence
- Session options configured for proper restoration

## Common Workflows

### Adding New Plugins
1. Create new file in `lua/plugins/` or add to existing file
2. Follow lazy.nvim specification format
3. Plugin will auto-load on next restart

### LSP Configuration
- Add servers to `lua/plugins/lsp.lua` in the `opts.servers` table
- Mason will handle installation automatically
- Server-specific configuration goes in the servers table

### Custom Keymaps
- Use the keymap utility in `lua/config/keymap.lua` for consistent which-key integration
- Follow the existing patterns for mode-specific bindings

## Environment Considerations

- Configuration detects VSCode vs standard Neovim and loads appropriate modules
- PATH is automatically configured for mise (development tool manager)
- Clipboard integration adapts to SSH vs local environments
- Plugin loading optimized with lazy loading where appropriate

## Plugin Development

The `lua/dev/` directory contains custom plugin development:
- `lua/dev/switch/`: Custom switching utilities

This development structure allows for local plugin prototyping before publishing or contributing upstream.
