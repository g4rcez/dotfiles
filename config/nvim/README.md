# Neovim Configuration

A modern, feature-rich Neovim configuration optimized for full-stack development with excellent LSP support, intelligent completion, and a productivity-focused workflow.

## Features

### 🎨 UI & Aesthetics

- **Theme**: Catppuccin Mocha with fallback to Tokyo Night
- **Statusline**: Lualine with mode indicator, diagnostics, git status, LSP info
- **Buffer Tabs**: Bufferline with LSP diagnostics per buffer
- **Winbar**: Dropbar for context-aware breadcrumbs and symbol hierarchy
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
- Oil.nvim - File explorer as a buffer (`<leader>so`)

### 💻 LSP & Language Support

Configured language servers for:

- **JavaScript/TypeScript**: typescript-tools.nvim with auto-complete function calls, inlay hints, code lens
- **Deno**: Automatic detection when `deno.json` present (alternative to TypeScript LSP)
- **Lua**: lua_ls with Neovim API completion via lazydev.nvim
- **Rust**: rust_analyzer
- **Web**: HTML, CSS, Tailwind CSS (50+ filetypes), CSS Variables
- **Docker**: Dockerfile, docker-compose with multiple language servers
- **YAML**: yamlls with schema support for GitHub workflows
- **Bash**: bashls
- **JSON**: jsonls with SchemaStore integration

#### Smart TypeScript/Deno Switching

The configuration automatically detects whether you're in a Node.js or Deno project:
- Projects with `package.json` → uses typescript-tools.nvim (vtsls-based)
- Projects with `deno.json` → uses denols
- Prevents conflicts by only running the appropriate server

#### LSP Servers Enabled

Located in `lua/config/lsp.lua`:

1. **html** - HTML language server
2. **bashls** - Bash scripting
3. **cssls** - CSS/SCSS/Less
4. **jsonls** - JSON with auto-schema detection
5. **css_variables** - CSS custom properties
6. **denols** - Deno runtime (TypeScript/JavaScript)
7. **dockerls** - Dockerfile
8. **docker_compose_language_service** - Docker Compose YAML
9. **docker_language_server** - Docker (Go-based)
10. **lua_ls** - Lua with third-party checks disabled
11. **oxlint** - Fast JavaScript/TypeScript linter
12. **rust_analyzer** - Rust
13. **tailwindcss** - Tailwind CSS with 50+ template types
14. **yamlls** - YAML with GitHub Actions schemas

### ⌨️ Completion

**Blink.cmp** - Fast, modern completion engine with:

- LSP completions with function signatures
- Snippet support via LuaSnip
- Path completion with file type icons
- Buffer completions
- Git completions (branches, commits)
- Conventional commits for git commit messages
- Environment variable completions
- Database completions (vim-dadbod)
- Fuzzy matching with frecency
- Ghost text preview
- Automatic documentation popup

**Completion Sources** (priority order):
1. lazydev - Neovim Lua API (score_offset: +100)
2. lsp - Language server (score_offset: +10)
3. git - Git branches/commits
4. path - File paths with icons
5. snippets - LuaSnip snippets
6. conventional_commits - Git commit messages
7. dadbod - Database completion
8. buffer - Current buffer words

**Keybindings**:
- `<Tab>` / `<CR>` - Accept completion
- `<C-j>` / `<C-k>` - Navigate completions
- `<C-Space>` - Show/toggle documentation
- `<C-c>` / `<Esc>` - Cancel
- `<C-/>` - Show signature help

### 🎯 Code Editing

- **Auto-pairs**: Intelligent bracket/quote pairing (nvim-autopairs)
- **Auto-tag**: Auto-close and auto-rename HTML/JSX tags (ts-autotag)
- **Emmet**: HTML/CSS abbreviation expansion
- **Template Strings**: Auto-convert to template literals when typing `${` in JS/TS
- **Surround**: vim-surround for quick wrapping/changing
- **Comments**: ts-comments for smart, language-aware comment toggling
- **Todo Comments**: Highlight and search TODO, FIXME, NOTE, etc.
- **Multi-cursor**: Advanced multi-cursor editing (multicursor.nvim)
- **UFO**: Advanced code folding with treesitter
- **Matchup**: Enhanced bracket matching
- **Dial.nvim**: Increment/decrement numbers, dates, and language-specific constants
- **Yanky**: Enhanced yank history with SQLite persistence

### 🔧 Formatting & Linting

Powered by **none-ls** (null-ls fork):

- **Formatters**: stylua (Lua), prettier (JS/TS/JSON/etc), rustywind (Tailwind), codespell (spelling)
- **Linters**: hadolint (Dockerfile), yamllint (YAML), stylelint (CSS), dotenv_linter (.env), oxlint (JS/TS)
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

**Octo.nvim** - GitHub integration:
- `<leader>oi` - List issues
- `<leader>op` - List pull requests
- `<leader>od` - List discussions
- `<leader>on` - List notifications
- `<leader>os` - Search GitHub

**Mini.diff**: `<leader>g=` - Toggle inline diff overlay (VSCode mode)

### 📝 LSP Features

**Navigation**:
- `gd` - Go to definition (with picker if multiple)
- `gD` - Go to declaration
- `gr` - Find references
- `gI` - Go to implementation
- `gy` - Go to type definition
- `grn` - Rename symbol
- `gra` - Code actions
- `K` - Hover documentation
- `[[` / `]]` - Jump to prev/next reference

**Diagnostics**:
- `]d` / `[d` - Next/previous diagnostic
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
- `<Tab><Tab>` - Quick buffer picker

**Windows**:
- `<C-s>` - Save file (normal and insert mode)
- `<leader>Z` - Zoom toggle (maximize window)

### 🔎 Search & Replace

- `<leader>sg` - Grep project
- `<leader>sw` - Grep word under cursor
- `<leader>sb` - Search buffer lines
- `<leader>sB` - Search in open buffers
- `<leader>sk` - Search all keymaps
- `<leader>sh` - Search help pages
- `/` patterns auto-center with `*` and `#`

### 🛠️ Additional Utilities

- **Zen Mode**: `<leader>z` - Distraction-free coding
- **Zoom**: `<leader>Z` - Maximize current window
- **Scratch Buffer**: `<leader>.` - Temporary notes
- **Terminal**: `<C-_>` - Toggle floating terminal
- **Undo History**: `<leader>su` - Browse undo tree
- **Icons**: `<leader>si` - Icon picker (Nerdy)
- **Notifications**: `<leader>nh` - Notification history
- **REST Client**: Kulala.nvim for `.http` and `.rest` files
- **Debug Adapter Protocol**: nvim-dap with UI for debugging
- **Test Runner**: Neotest framework (adapters not configured)

### 🎓 Editor Behavior

**Smart Defaults**:
- Leader key: `Space`
- Line numbers with relative numbering
- Smart case-insensitive search
- Persistent undo history (1000 levels)
- Auto-save with autosave plugin
- Mouse support enabled
- System clipboard integration (`<leader>cy` yanks file path)
- 10-line scroll offset
- No swap files
- 300ms timeout for which-key
- Conceal level 0 (show everything)

**Folding**:
- Provider: nvim-ufo with expression-based folding
- Level 99 (open by default)
- `zo` - Toggle fold
- `zR` - Open all folds
- `zM` - Close all folds
- `zm` - Close folds with depth

**Text Editing**:
- `J` - Join lines (keeps cursor position)
- `0` - Go to first non-whitespace character
- `vv` - Select entire line
- `+` / `-` - Increment/decrement numbers (dial.nvim)
- `>` / `<` - Indent/dedent (with visual mode reselect)
- `<BS>` - Black hole register prefix
- `p` in visual mode - Paste without yanking

**Multi-cursor** (visual mode):
- `<C-k>` - Add cursor above
- `<C-j>` - Add cursor below
- `<C-n>` - Match next word
- `<leader>nn` - New match cursor
- `<leader>ns` - Skip match
- `<leader>nN` - Previous match
- `<leader>nS` - Skip previous match
- `<leader>nA` - Add all matches
- `<leader>J` - Join with next match

## Installation

### Prerequisites

1. **Neovim** 0.10+ (preferably 0.11+ for latest LSP features)
2. **Git**
3. **A Nerd Font** (e.g., JetBrains Mono Nerd Font)
4. **ripgrep** (for grep functionality)
5. **fd** (for file finding)
6. **Node.js** and **npm** (for LSP servers)

### Quick Start

1. This configuration is part of the main dotfiles repository:

```bash
# Clone dotfiles repository
git clone https://github.com/g4rcez/dotfiles $HOME/dotfiles
cd $HOME/dotfiles

# Run installation (includes Neovim config symlink)
bash install
```

2. Install language servers:

```bash
# JavaScript/TypeScript ecosystem
npm i -g vscode-langservers-extracted  # html, css, json
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
brew install stylua
```

3. Launch Neovim:

```bash
nvim
```

Lazy.nvim will automatically install all plugins on first launch.

4. LSP servers will be installed automatically via Mason.

## Configuration Structure

```
~/.config/nvim/
├── init.lua                      # Entry point
├── lazy-lock.json                # Plugin version lock file
├── .stylua.toml                  # Lua formatting config
├── CLAUDE.md                     # AI assistant guidance
├── lua/
│   ├── config/
│   │   ├── lazy.lua              # Lazy.nvim bootstrap
│   │   ├── options.lua           # Vim options
│   │   ├── keymaps.lua           # Global keymaps with custom bind helper
│   │   ├── autocmds.lua          # Autocommands
│   │   └── lsp.lua               # LSP configurations (vim.lsp.config/enable)
│   └── plugins/
│       ├── blinkcmp.lua          # Completion engine
│       ├── nvimlspconfig.lua     # LSP handlers & attach
│       ├── typescriptools.lua    # TypeScript LSP
│       ├── mason.lua             # LSP/tool installer
│       ├── snacks.lua            # Picker, git, terminal, zen mode
│       ├── format.lua            # none-ls formatters & linters
│       ├── treesitter.lua        # Syntax highlighting
│       ├── ui.lua                # Catppuccin, noice, dropbar
│       ├── lualine.lua           # Statusline
│       ├── bufferline.lua        # Buffer tabs
│       ├── git.lua               # Gitsigns integration
│       ├── octo.lua              # GitHub integration
│       ├── code.lua              # Editing helpers
│       ├── whichkey.lua          # Which-key menu
│       ├── autosave.lua          # Auto-save
│       ├── multicursor.lua       # Multi-cursor
│       ├── yanky.lua             # Yank history
│       ├── dial.lua              # Increment/decrement
│       ├── oilnvim.lua           # File explorer
│       ├── kulalahttp.lua        # HTTP client
│       ├── debug.lua             # DAP configuration
│       ├── tests.lua             # Neotest framework
│       └── ...
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

## Key Architectural Patterns

**LSP Configuration**: Uses Neovim's built-in `vim.lsp.config` and `vim.lsp.enable` pattern (not lspconfig) for base server setup. Configuration is split:
- `lua/config/lsp.lua` - Server configs (capabilities, settings, filetypes)
- `lua/plugins/nvimlspconfig.lua` - LspAttach autocommands and keymaps

**Dual LSP Strategy**: Intelligently switches between typescript-tools.nvim (Node.js projects) and denols (Deno projects) based on project files.

**Keymap System**: Custom helper in `keymaps.lua` with mode-specific functions:
- `bind.normal`, `bind.visual`, `bind.insert`, `bind.cmd`, `bind.nx`

**Plugin Organization**: Modular files by function in `lua/plugins/`

**Common Keybind Prefixes**:
- `<leader>f*` - File/find operations
- `<leader>s*` - Search operations
- `<leader>g*` - Git operations
- `<leader>b*` - Buffer operations
- `<leader>c*` - Code actions
- `<leader>h*` - Git hunk operations
- `<leader>t*` - Toggle operations
- `<leader>o*` - Octo (GitHub)
- `<leader>n*` - Multicursor
- `gr*` - LSP goto operations

## Troubleshooting

### LSP Not Working

1. Check if server is running: `:LspInfo`
2. Check Mason installations: `:Mason`
3. Check logs: `:Snacks picker notifications`
4. Restart LSP: `:LspRestart`

### Completion Not Showing

1. Verify blink.cmp is loaded: `:Lazy`
2. Check LSP is attached: `:LspInfo`
3. Check completion sources: `:lua print(vim.inspect(require('blink.cmp').get_sources()))`

### Formatting Not Working

1. Check none-ls sources are loaded
2. Verify formatter is installed: `which prettier`
3. Try manual format: `<leader>cf`

## Language-Specific Features

**JavaScript/TypeScript**:
- typescript-tools.nvim with separate diagnostic server
- Code lens for all constructs
- JSX auto-close tags
- Complete function calls
- Template string auto-conversion
- Tailwind CSS completions (50+ filetypes)

**Lua**:
- lua_ls with code lens and inlay hints
- lazydev.nvim for Neovim API completions
- stylua formatter

**Rust**:
- rust_analyzer with full features

**Docker**:
- Multiple language servers (dockerls, compose, docker-language-server)
- hadolint linting

**Web Development**:
- HTML, CSS, Tailwind CSS, CSS Variables
- Emmet abbreviations
- Color highlighting (hex, RGB, HSL, Tailwind)
- Auto-tag closing/renaming

## Credits

Built with:
- [lazy.nvim](https://github.com/folke/lazy.nvim) - Plugin manager
- [blink.cmp](https://github.com/Saghen/blink.cmp) - Completion
- [snacks.nvim](https://github.com/folke/snacks.nvim) - Utilities
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Syntax
- [catppuccin](https://github.com/catppuccin/nvim) - Theme
- [typescript-tools.nvim](https://github.com/pmizio/typescript-tools.nvim) - TypeScript LSP
- And many more excellent plugins from the Neovim community

## License

This configuration is personal and provided as-is for reference.
