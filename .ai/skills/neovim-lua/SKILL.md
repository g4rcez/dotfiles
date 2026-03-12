---
description: Review Neovim Lua configuration for correctness, performance, and idiomatic patterns
argument-hint: <file-or-pattern>
---

# Neovim Lua Review

Review these files for compliance: $ARGUMENTS

Read files, check against rules below. Output concise but comprehensive—sacrifice grammar for brevity. High signal-to-noise.

## Rules

### Options

- `vim.opt.name = value` — not `vim.o`/`vim.bo`/`vim.wo` (opt auto-scopes)
- `vim.opt.name:append(value)` / `:remove()` / `:prepend()` for list/set options
- Never `vim.cmd("set ...")` — always `vim.opt`
- Buffer-local: `vim.bo[bufnr].name` or `vim.opt_local` inside `FileType` autocmd

### Keymaps

- `vim.keymap.set(mode, lhs, rhs, opts)` — not deprecated `vim.api.nvim_set_keymap`
- Always pass `{ desc = "..." }` — shows in which-key and `:map`
- `{ noremap = true, silent = true }` for most mappings (default noremap in `vim.keymap.set`)
- Prefer `<leader>` mappings in `opts` table, not inside `config` callbacks scattered across plugins
- `vim.keymap.del(mode, lhs)` to remove mappings

### Autocmds

- `vim.api.nvim_create_autocmd(event, opts)` — not `vim.cmd("autocmd ...")`
- Group with `vim.api.nvim_create_augroup("MyGroup", { clear = true })`
- Pass `group` to every `nvim_create_autocmd` call
- `buffer = bufnr` for buffer-local autocmds; `pattern` for file patterns

### lazy.nvim Plugin Specs

- `opts = {}` for plugins that only need option passing — skip `config` callback
- `config = function(_, opts) require("plugin").setup(opts) end` when setup call needed
- `dependencies = {}` for runtime deps; they load before the parent
- Lazy loading:
  - `event = "VeryLazy"` for non-critical UI plugins
  - `event = "BufReadPre"` / `"BufNewFile"` for file-type agnostic editing plugins
  - `ft = { "lua", "python" }` for filetype-specific plugins
  - `cmd = { "PluginCmd" }` for command-triggered plugins
  - `keys = { ... }` for keymap-triggered plugins
- Avoid `lazy = false` unless plugin must load at startup (e.g., colorscheme, options)
- `build` for post-install commands; `version` to pin releases

### LSP

- Neovim 0.11+: `vim.lsp.config("server", opts)` + `vim.lsp.enable("server")`
- Pre-0.11: `require("lspconfig").server.setup(opts)`
- `on_attach` in LSP setup for buffer-local keymaps; use `vim.lsp.buf.*` APIs
- `capabilities` from `cmp_nvim_lsp` or `blink.cmp` if using completion
- Diagnostic config: `vim.diagnostic.config({ ... })` once at startup
- `vim.lsp.buf.format` over deprecated `vim.lsp.buf.formatting`

### Modules & Require

- Module results are cached after first `require`; avoid in hot paths — cache at module level
- `pcall(require, "module")` for optional dependencies
- Return tables from modules; avoid side effects at require time
- File → module mapping: `lua/myplugin/init.lua` → `require("myplugin")`

### Colorscheme & UI

- Wrap colorscheme in `pcall`: `local ok, _ = pcall(vim.cmd.colorscheme, "theme")`
- Provide fallback: `if not ok then vim.cmd.colorscheme("haiku") end`
- Set `vim.o.termguicolors = true` before loading colorscheme
- `vim.opt.background = "dark"` before colorscheme if theme supports it

### Performance

- Defer non-critical plugins with `event = "VeryLazy"` or `vim.defer_fn`
- Avoid synchronous `io` in startup path — use async or defer
- `vim.loader.enable()` at top of `init.lua` — bytecode caching
- Profile with `:Lazy profile` or `--startuptime` flag

### Anti-patterns

- `require("plugin")` without `pcall` · `vim.cmd("set ...")` · `vim.cmd("autocmd ...")`
- `vim.api.nvim_set_keymap` (deprecated) · `vim.o.xxx` instead of `vim.opt.xxx`
- `lazy = false` on lazy-loadable plugins · `opts` callback calling `require` (use `dependencies`)
- Hardcoded colorscheme without pcall · missing `{ clear = true }` on augroup

## Output Format

Group by file. Use `file:line` format (VS Code clickable). Terse findings.

```text
## lua/config/options.lua

lua/config/options.lua:8 - vim.cmd("set number") → vim.opt.number = true
lua/config/options.lua:15 - vim.o.wrap → vim.opt.wrap (loses scoping)

## lua/plugins/lsp.lua

lua/plugins/lsp.lua:22 - vim.api.nvim_set_keymap → vim.keymap.set
lua/plugins/lsp.lua:47 - require("lspconfig") in hot path → cache at top of module
lua/plugins/lsp.lua:63 - missing pcall on colorscheme load

## lua/plugins/ui.lua

✓ pass
```

State issue + location. Skip explanation unless fix non-obvious. No preamble.
