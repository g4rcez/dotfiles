# Neovim as Terminal Multiplexer

**Date:** 2026-04-27
**Status:** Approved

## Goal

Replace tmux entirely with a single Neovim instance that manages multiple projects simultaneously, using tab pages as workspace containers — without changing the buffer-centric editing workflow.

## Architecture

Three layers work together:

**Workspace layer** — Each Neovim tab page is one project workspace. On creation, `tcd` sets the tab-local working directory to the project root. All file opens, terminals, and git operations within that tab inherit the correct cwd automatically. Workspace commands (`<leader>wo`, etc.) abstract away `:tabnew` so the user never interacts with tab pages directly.

**Session layer** — `resession.nvim` replaces `persistence.nvim`. It saves a named session per project, keyed by the tab-local cwd (`vim.fn.fnamemodify(vim.fn.getcwd(-1, 0), ":~")`). The session stores open buffers, window layouts, and cwd. A `"last"` session captures the full multi-workspace state on exit and restores it on startup. Dashboard shortcut `S` triggers `resession.load("last")` manually.

**Terminal layer** — Snacks terminal (already enabled) handles terminal buffers. Terminals open with the current tab's cwd. No new plugin required.

**Git integration** — `nvr` (neovim-remote) is installed as a system tool via mise and set as `$GIT_EDITOR` in zsh config. Git operations (`commit`, `rebase -i`, diffs) open files in the running Neovim instance as buffers in the current workspace instead of spawning a nested editor.

## Plugin Changes

**Remove:**
- `folke/persistence.nvim` — delete `config/nvim/lua/plugins/session.lua`

**Add:**
- `stevearc/resession.nvim` — create `config/nvim/lua/plugins/session.lua` with resession spec
- `nvr` system tool — add `neovim-remote` to `config/mise/config.toml` under `[tools]`

**Modify:**
- `config/nvim/lua/plugins/bufferline.lua` — enable tab-scoped buffer grouping so bufferline only shows buffers belonging to the current tab page
- `config/nvim/lua/plugins/snacks.lua` — add `S` key to dashboard for session restore
- `config/zsh/` (alias.sh or a new env file) — set `GIT_EDITOR` to `nvr --remote-tab-wait` so git opens files in the running instance

## Keymaps

All workspace keymaps use `<leader>w` prefix. Added to `config/nvim/lua/config/keymaps.lua`.

- `<leader>wo` — open workspace: launch Snacks directory picker, on confirm `:tabnew` + `tcd <dir>` + restore project session if one exists for that path
- `<leader>wc` — close workspace: save current project session, then `:tabclose` (if multiple tabs) or clear all buffers (if last tab)
- `<leader>ws` — save current workspace session manually (keyed by tab-local cwd)
- `<leader>wt` — toggle Snacks terminal in current workspace (inherits tab cwd)
- `<leader>1` through `<leader>9` — jump to workspace by tab index

## Session Lifecycle

- **Dashboard restore:** Snacks dashboard item with key `S` and label `Restore Session` calls `resession.load("last")` — this is the primary way to restore on startup; auto-restoring via `VimEnter` is avoided because it would conflict with the dashboard rendering
- **Auto-save on exit:** `VimLeavePre` autocmd calls `resession.save("last")` to capture all open workspaces
- **Per-project save:** `<leader>ws` saves a named session for the current tab's project path, enabling individual project restore later via `<leader>wo`

## Bufferline Scoping

Bufferline is configured to group buffers by tab page so each workspace only shows its own buffers. This uses bufferline's built-in `groups` or the tabpage buffer filtering available in recent versions. The visual result is that switching workspaces (`<leader>1-9`) also switches the bufferline view.

## Constraints & Decisions

- Tab page switching via `<leader>1-9` uses `vim.cmd("tabnext " .. n)` — simple and reliable
- `GIT_EDITOR=nvr --remote-tab-wait` makes git wait for the buffer to be closed (`:bd`) before proceeding with the commit/rebase
- Terminal buffers are not persisted across sessions (Snacks terminal recreates them on demand)
- The tabline UI (showing project names) is out of scope for this iteration and can be addressed separately
- bufferline's tab-scoping may require `mode = "tabs"` depending on version — verify during implementation
