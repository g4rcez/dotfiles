# Neovim

Neovim is the main editor. Plugin specs use lazy.nvim. Read `AGENTS.md` (Neovim section) and the `neovim-lua` skill first for the hard rules (augroups, `vim.opt`, Snacks picker `items=`, treesitter `; extends`, `persistence.nvim`, tab pages as workspaces).

## Layout

- `config/nvim/lua/plugins/*.lua`: one spec file per capability. Grep here before adding a plugin: the capability may already exist.
- `config/nvim/lua/config/*.lua`: options, keymaps, LSP, terminal, diagnostics and other built-in behavior.
- `config/nvim/lua/mention_ls/`: a built-in LSP for `@` mentions (files and skills). It replaced the old `pi` and `filemention` plugins.
- `config/nvim/tests/*.lua`: headless tests (`smoke.lua`, `contextual_completion.lua`, `mention_ls.lua`).
- The user prefers built-in features over third-party plugins (see recent commits "replace third-party plugins with built-in features"). Default to a small local module under `config/nvim/lua/` before a new plugin.

## Review and git tooling that already exists

Check these before designing a new review tool: `esmuellert/codediff.nvim`, `dlyongemallo/diffview-plus.nvim`, `kokusenz/deltaview.nvim`, `cvlmtg/inline-diff.nvim`, `vim-fugitive`, `headhunter.nvim` (all in `plugins/git.lua`), `pwntester/octo.nvim` (GitHub PRs and issues, `plugins/octo.lua`), `TheNoeTrevino/haunt.nvim` (line annotations with signs and virtual text, `plugins/haunt.lua`), and neotest in `plugins/tests.lua`.

## Building a code-review plugin: the shape that fits this workflow

This is a design direction, not an approved spec. Confirm scope with the user before building.

The loop the user wants: an AI session changes code, the user reviews the diff in Neovim, writes comments on lines, and sends them back to that AI session, with the tests running.

1. **Source of the diff:** `git diff` of the working tree or of a worktree/branch (`git diff <base>...HEAD`). Reuse `codediff` or `diffview` for display. Do not write a diff renderer.
2. **Comments:** check whether `haunt.nvim` annotations can carry them before writing a store. If a store is needed, keep it as one file per review under `.git/` (like `task-checkpoint`), never in the working tree.
3. **Send back:** export comments as a markdown block (`path:line`, quoted line, comment) and deliver it to the AI pane with `rex send -s <session> -b <block> "<text>"` plus `rex send-key ... enter`. `bin/ai` already knows how to find the agent pane (`cmd_sessions_rows`).
4. **Close the loop:** after the AI replies, re-open the diff on the new state. Run the area checks (`references/verify.md`) and show the result in the review buffer.
5. **Keyboard first:** every action gets a keymap with a `desc`, registered through which-key conventions in `plugins/whichkey.lua`. Check `config/nvim/lua/config/keymaps.lua` and the plugin files for key conflicts before choosing keys.

## Verify

1. `stylua --check` on changed Lua files.
2. `nvim --headless -u NONE -l config/nvim/tests/smoke.lua` and any test matching the change.
3. For a new module, add `config/nvim/tests/<name>.lua` with literal expectations, and add the line to `bin/repo-check` only if the user approves.
4. Say what was not exercised (UI, pickers, real LSP). Do not claim UI works from a headless run.
