# Neovim Configuration

A modern, feature-rich Neovim configuration optimized for full-stack development with excellent LSP support, intelligent completion, and a productivity-focused workflow.

## Features

### 🎨 UI & Aesthetics

- **Theme**: Catppuccin Mocha with fallback to Tokyo Night
- **Statusline**: Heirline with custom components showing mode, diagnostics, git status, LSP info
- **Winbar**: Dropbar for context-aware breadcrumbs
- **Notifications**: Noice.nvim for beautiful command-line and notification UI
- **Color Highlighting**: Live preview of hex, RGB, HSL colors and Tailwind classes

### 🔍 Navigation & Fuzzy Finding

Powered by **Snacks.nvim picker** (telescope-inspired layout):

- `<leader><space>` - Find files (with frecency and smart matching)
- `<leader>fg` / `<C-S-f>` - Live grep across project
- `<leader>fb` - Browse buffers
- `<leader>fr` - Recent files
- `<leader>ft` - Treesitter symbols
- `<leader>fe` - File explorer (Snacks explorer)

### 💻 LSP & Language Support

Configured language servers for:

- **JavaScript/TypeScript**: vtsls with auto-complete function calls, inlay hints
- **Deno**: Automatic switching from vtsls when `deno.json` detected
- **Lua**: lua_ls with Neovim API completion
- **Rust**: rust_analyzer
- **C#**: (via LSP)
- **Web**: HTML, CSS, Tailwind CSS with intelligent completions
- **Docker**: Dockerfile and docker-compose language servers
- **YAML**: yamlls with schema support for GitHub workflows
- **Bash**: bashls

#### Smart TypeScript/Deno Switching

The configuration automatically detects whether you're in a Node.js or Deno project:
- Projects with `package.json` → uses vtsls
- Projects with `deno.json` → uses denols
- Prevents conflicts by stopping the wrong server

### ⌨️ Completion

**Blink.cmp** - Fast, modern completion engine with:

- LSP completions with function signatures
- Snippet support via LuaSnip
- Path completion with file type icons
- Buffer completions
- Git completions (branches, commits)
- Conventional commits for git commit messages
- Environment variable completions
- Database completions (dadbod)
- Fuzzy matching with frecency
- Ghost text preview
- Automatic documentation popup

**Keybindings**:
- `<Tab>` / `<CR>` - Accept completion
- `<C-j>` / `<C-k>` - Navigate completions
- `<C-Space>` - Show/toggle documentation
- `<C-c>` / `<Esc>` - Cancel

### 🎯 Code Editing

- **Auto-pairs**: Intelligent bracket/quote pairing
- **Auto-tag**: Auto-close and auto-rename HTML/JSX tags
- **Emmet**: `<leader>ce` - Expand Emmet abbreviations
- **Template Strings**: Auto-convert to template literals when typing `${` in JS/TS
- **Surround**: vim-surround for quick wrapping/changing
- **Comments**: ts-comments for smart comment toggling
- **Todo Comments**: Highlight and search TODO, FIXME, NOTE, etc.
- **Multi-cursor**: Advanced multi-cursor editing
- **UFO**: Advanced code folding with treesitter

### 🔧 Formatting & Linting

Powered by **null-ls**:

- **Formatters**: stylua, prettier, rustywind
- **Linters**: hadolint, yamllint, stylelint, dotenv_linter, oxlint
- **Spell Check**: codespell with en-US and pt-BR support
- `<leader>cf` - Format current buffer
- `<leader>co` - Organize imports

### 🔀 Git Integration

**Gitsigns** for inline git decorations:
- `]c` / `[c` - Navigate between hunks
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hS` - Stage buffer
- `<leader>hR` - Reset buffer
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line
- `<leader>hd` - Diff against index
- `<leader>tb` - Toggle blame line

**Snacks.nvim** git pickers:
- `<leader>gs` - Git status
- `<leader>gb` - Git branches
- `<leader>gl` - Git log
- `<leader>gL` - Git log for current line
- `<leader>gd` - Git diff (hunks)
- `<leader>gf` - Git log for current file
- `<leader>gB` - Git browse (open in browser)
- `<leader>gg` - Lazygit integration

**Mini.diff**: `<leader>g=` - Toggle inline diff overlay

### 📝 LSP Features

**Navigation**:
- `gd` - Go to definition (with picker if multiple)
- `gD` - Go to declaration
- `gr` - Find references
- `gI` - Go to implementation
- `gy` - Go to type definition
- `grn` - Rename symbol
- `gra` - Code actions

**Diagnostics**:
- `]d` / `[d` - Next/previous diagnostic (warnings+)
- `<leader>xd` - Open diagnostic float
- `<leader>sd` - Search diagnostics (workspace)
- `<leader>sD` - Search diagnostics (buffer)
- `<leader>cq` - Quickfix list

**Other**:
- `<leader>th` - Toggle inlay hints
- `<leader>ss` - LSP document symbols
- `<leader>sS` - LSP workspace symbols

### 📦 Buffer & Window Management

**Buffers**:
- `<C-h>` / `<C-l>` - Previous/next buffer
- `<leader>bd` / `<leader>qq` - Delete buffer
- `<leader>bo` - Close all buffers except current
- `<leader>bp` - Pin buffer
- `<leader>br` - Go to alternate buffer
- `<leader>,` / `<leader><Tab>` - Buffer picker

**Windows**:
- Standard vim split commands
- `<C-s>` - Save file (normal and insert mode)

### 🔎 Search & Replace

- `<leader>sg` - Grep project
- `<leader>sw` - Grep word under cursor
- `<leader>sb` - Search buffer lines
- `<leader>sB` - Search in open buffers
- `/` patterns auto-center with `*` and `#`

### 🛠️ Additional Utilities

- **Zen Mode**: `<leader>z` - Distraction-free coding
- **Zoom**: `<leader>Z` - Maximize current window
- **Scratch Buffer**: `<leader>.` - Temporary notes
- **Terminal**: `<C-_>` - Toggle floating terminal
- **Undo History**: `<leader>su` - Browse undo tree
- **Keymaps**: `<leader>sk` - Search all keymaps
- **Help**: `<leader>sh` - Search help pages
- **Icons**: `<leader>si` - Icon picker (Nerdy)
- **Notifications**: `<leader>nh` - Notification history

### 🎓 Editor Behavior

**Smart Defaults**:
- Leader key: `Space`
- Line numbers with relative numbering
- Smart case-insensitive search
- Persistent undo history
- Auto-save with autosave plugin
- Mouse support enabled
- System clipboard integration (`<leader>cy` yanks file path)
- 10-line scroll offset
- No swap files
- 300ms timeout for which-key
- Conceal level 0 (show everything)

**Folding**:
- Expression-based folding with UFO
- `zo` - Toggle fold
- `zR` - Open all folds
- `zM` - Close all folds
- `zm` - Close folds with depth

**Text Editing**:
- `J` - Join lines (Primeagen style, keeps cursor position)
- `0` - Go to first non-whitespace character
- `vv` - Select entire line
- `+` / `-` - Increment/decrement numbers
- `>` / `<` - Indent/dedent (with visual mode reselect)
- `<BS>` - Black hole register prefix
- `p` in visual mode - Paste without yanking

**Sorting** (visual mode):
- `<leader>sa` - Sort alphabetically
- `<leader>sn` - Sort numerically
- `<leader>su` - Sort unique
- `<leader>sr` - Reverse
- `<leader>ss` - Sort by line length

## Installation

### Prerequisites

1. **Neovim** 0.10+ (preferably 0.11+ for latest LSP features)
2. **Git**
3. **A Nerd Font** (for icons)
4. **ripgrep** (for grep functionality)
5. **fd** or **find** (for file finding)
6. **Node.js** and **npm** (for LSP servers)

### Quick Start

1. Clone this configuration:

```bash
git clone <your-repo-url> ~/.config/nvim
```

2. Install language servers:

```bash
# JavaScript/TypeScript ecosystem
npm i -g vscode-langservers-extracted
npm i -g @vtsls/language-server
npm i -g tailwindcss-language-server
npm i -g css-variables-language-server
npm i -g bash-language-server
npm i -g dockerfile-language-server-nodejs
npm install -g @microsoft/compose-language-service

# Linters and formatters
npm i -g prettier
npm i -g oxlint

# Lua
brew install stylua  # or your package manager
```

3. Launch Neovim:

```bash
nvim
```

Lazy.nvim will automatically install all plugins on first launch.

4. LSP servers will be installed automatically via Mason, or you can manually install specific servers.

## Configuration Structure

```
~/.config/nvim/
├── init.lua                      # Entry point
├── lazy-lock.json                # Plugin version lock file
├── .stylua.toml                  # Lua formatting config
├── lua/
│   ├── config/
│   │   ├── lazy.lua              # Lazy.nvim bootstrap
│   │   ├── options.lua           # Vim options
│   │   ├── keymaps.lua           # Global keymaps
│   │   ├── autocmds.lua          # Autocommands
│   │   └── lsp.lua               # LSP configurations
│   └── plugins/
│       ├── blinkcmp.lua          # Completion engine
│       ├── lspconfig.lua         # LSP handlers & Mason
│       ├── snacks.lua            # Picker, git, terminal, etc.
│       ├── format.lua            # Formatters & linters
│       ├── treesitter.lua        # Syntax highlighting
│       ├── ui.lua                # UI components
│       ├── git.lua               # Git integration
│       ├── code.lua              # Code editing helpers
│       ├── whichkey.lua          # Which-key menu
│       ├── autosave.lua          # Auto-save
│       ├── multicursor.lua       # Multi-cursor
│       ├── matchup.lua           # Match brackets
│       ├── mini.lua              # Mini.nvim modules
│       ├── oilnvim.lua           # Oil file manager
│       ├── session.lua           # Session management
│       ├── mason.lua             # LSP installer
│       ├── codeactions.lua       # Code actions
│       ├── inlinediagnostic.lua  # Inline diagnostics
│       └── ...
└── CLAUDE.md                     # AI assistant guidance
```

## Customization

### Adding a New Plugin

Create or edit a file in `lua/plugins/`:

```lua
return {
    {
        "author/plugin-name",
        event = "VeryLazy",  -- or cmd, ft, keys for lazy-loading
        opts = {
            -- plugin options
        },
        keys = {
            { "<leader>x", "<cmd>PluginCommand<cr>", desc = "Description" },
        },
    },
}
```

### Adding a Keymap

In `lua/config/keymaps.lua`:

```lua
bind.normal("<leader>xx", "<cmd>YourCommand<cr>", { desc = "Your description" })
```

### Adding an LSP Server

In `lua/config/lsp.lua`:

```lua
vim.lsp.config("server_name", {
    capabilities = capabilities,
    settings = {
        -- server-specific settings
    },
})

-- Then add to the enable list
vim.lsp.enable {
    -- ... existing servers
    "server_name",
}
```

### Changing Options

In `lua/config/options.lua`:

```lua
vim.opt.your_option = value
```

## Troubleshooting

### LSP Not Working

1. Check if server is running: `:LspInfo`
2. Check Mason installations: `:Mason`
3. Check logs: `:Snacks picker notifications`

### Completion Not Showing

1. Verify blink.cmp is loaded: `:Lazy`
2. Check LSP is attached: `:LspInfo`
3. Restart LSP: `:LspRestart`

### Formatting Not Working

1. Check null-ls sources: `:lua print(vim.inspect(require('null-ls').get_sources()))`
2. Verify formatter is installed (e.g., `which prettier`)
3. Try manual format: `<leader>cf`

## Credits

Built with:
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [blink.cmp](https://github.com/Saghen/blink.cmp) - Completion
- [snacks.nvim](https://github.com/folke/snacks.nvim) - Utilities
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax
- [catppuccin](https://github.com/catppuccin/nvim) - Theme
- And many more excellent plugins from the Neovim community

## License

This configuration is personal and provided as-is for reference.
