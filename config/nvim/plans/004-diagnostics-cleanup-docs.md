# Plan 004: Activate diagnostics, remove dead modules, and refresh documentation

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report — do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 9e0ca10..HEAD -- init.lua lua/config/diagnostics.lua lua/config/autotag.lua lua/nvconfig.lua lua/config/keymaps.lua README.md CLAUDE.md`

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: MED
- **Depends on**: 003-keymaps-and-mini.md
- **Category**: tech-debt
- **Status**: Complete
- **Planned at**: commit `9e0ca10`, 2026-09-14

## Why this matters

The repository contains a 757-line diagnostics module that is imported but never initialized, so the active UI is only Neovim's standard diagnostics configuration. Activating it without first fixing its edge cases would expose a nil dereference in its statuscolumn and register an ungrouped autocmd. Two other local modules are unreferenced, and the README/CLAUDE documentation describes plugins and architecture that are no longer present.

## Current state

- `init.lua:23` only executes `require "config.diagnostics"`; it does not call `setup()`.
- `lua/config/diagnostics.lua:488-506` reads `data.start_row` before checking whether `data` exists.
- `lua/config/diagnostics.lua:721-750` creates a cursor autocmd without an augroup.
- `lua/config/keymaps.lua` contains a custom `<leader>xd` diagnostic float toggle. This plan will make `<leader>xd` call the configured diagnostics panel instead.
- `lua/config/autotag.lua` and `lua/nvconfig.lua` have no callers. `ts-autotag.nvim` in `lua/plugins/code.lua` is the active auto-tag implementation.
- `README.md` describes none-ls, nvim-autopairs, vim-surround, and an outdated LSP/plugin architecture. `CLAUDE.md` also describes `nvimlspconfig.lua` as the location of LSP attach keymaps and calls the statusline Heirline even though the implementation uses Lualine.

## Commands you will need

| Purpose | Command | Expected on success |
| --- | --- | --- |
| Syntax | `nvim --headless -u NONE -c 'lua local n=0; for _,f in ipairs(vim.fn.glob("lua/**/*.lua",false,true)) do local c,e=loadfile(f); if not c then print(f,e); n=n+1 end end; if n>0 then vim.cmd("cquit 1") end' -c 'qa!'` | Exit 0 |
| Diagnostics smoke | `nvim --headless -u init.lua '+lua local d=require("config.diagnostics"); vim.diagnostic.set(vim.api.nvim_create_namespace("audit"),0,{{lnum=0,col=0,end_col=4,severity=vim.diagnostic.severity.ERROR,message="audit"}}); assert(pcall(d.hover,0)); d.close()' '+qa!'` | Exit 0 |
| Existing test | `nvim --headless -u NONE -l tests/contextual_completion.lua` | Prints `contextual_completion: PASS` |
| Reference search | `grep -RIn -e 'config.autotag' -e 'nvconfig' -e 'diagnostics.setup' init.lua lua README.md CLAUDE.md` | Only the intended diagnostics setup reference remains |

## Scope

**In scope**:

- `init.lua`
- `lua/config/diagnostics.lua`
- `lua/config/keymaps.lua` (only the `<leader>xd` mapping and adjacent toggle helper)
- `lua/config/autotag.lua` (delete after reference check)
- `lua/nvconfig.lua` (delete after reference check)
- `README.md`
- `CLAUDE.md`

**Out of scope**:

- The clipboard security issue in `lua/plugins/mini.lua`.
- Plugin upgrades, dependency changes, or lockfile changes.
- Changes to the active `ts-autotag.nvim` plugin.
- Keymap conflicts owned by Plan 003 except the diagnostics mapping handoff.
- Existing modified or untracked files not listed above.

## Git workflow

- Run `git diff --cached --quiet --` before implementation; stop if staged changes exist.
- Preserve all unstaged and untracked work. Do not reset, clean, stage, or commit.

## Steps

### Step 1: Make the custom diagnostics module safe

In `lua/config/diagnostics.lua`:

1. Check `data` before reading `data.start_row` in `_G.fancy_diagnostics_statuscolumn`.
2. Fix the width calculation so it retains the maximum diagnostic message width, not only the last item width.
3. Add an augroup with `{ clear = true }` for the setup cursor autocmd, following the repository's autocmd convention.
4. Define the `FancyDiagnostic*` and `FancyDiagnostic*Icon` highlight groups by linking them to the existing `Diagnostic*`, `DiagnosticVirtualText*`, and `NormalFloat` groups. Keep the links compatible with Tokyo Night.
5. Keep optional Markview and beacon integrations guarded by `package.loaded` checks.

**Verify**: run the syntax command → exit 0.

### Step 2: Activate the module without creating a keymap conflict

In `init.lua`, on the native-Neovim path, call `require("config.diagnostics").setup { keymap = false }` after the LSP diagnostic configuration is loaded. In `lua/config/keymaps.lua`, remove the local diagnostic-float toggle and map `<leader>xd` to `require("config.diagnostics").hover` with description `Show diagnostics`.

Do not add a second default `L` mapping. The existing LSP `<leader>dd` cursor float remains unchanged.

**Verify**: run the diagnostics smoke command → exit 0 with no nil dereference; `:verbose nmap <Space>xd` identifies the custom diagnostics hover mapping.

### Step 3: Remove unreferenced modules

Before deletion, run the reference-search command. If there are no callers beyond the files themselves, delete `lua/config/autotag.lua` and `lua/nvconfig.lua`. Do not delete `config.diagnostics.lua`; it is now active.

**Verify**: repeat the reference search → no `config.autotag` or `nvconfig` references remain and exactly one `diagnostics.setup` call exists.

### Step 4: Refresh documentation

Update `README.md` and `CLAUDE.md` to match the implementation:

- Conform.nvim plus nvim-lint, not none-ls.
- mini.pairs and mini.surround, not nvim-autopairs/vim-surround.
- LSP setup and attach keymaps live in `lua/config/lsp.lua`; `lua/plugins/nvimlspconfig.lua` only declares the plugin and Fidget dependency.
- Lualine is the statusline.
- Document the project-aware ESLint/Oxlint rule: Oxlint wins when both configs exist.
- Document the final keymap ownership table from Plan 003, including Yanky on `<leader>py`.
- Remove claims for tools or features not configured, including codespell, dotenv_linter, and none-ls.

Do not rewrite unrelated prose or add new feature claims.

**Verify**: `grep -n 'none-ls\|nvim-autopairs\|vim-surround\|Heirline\|config.autotag\|nvconfig' README.md CLAUDE.md` → no matches.

## Test plan

- Synthetic diagnostic smoke test covering an error item and closing the custom window.
- Reference search before and after deleting dead modules.
- Documentation search for removed implementation names.
- Run the existing contextual completion test unchanged.

## Done criteria

- [x] `config.diagnostics` is initialized exactly once in native Neovim mode.
- [x] `<leader>xd` opens the custom diagnostics panel without conflicting with `<leader>dd`.
- [x] No statuscolumn nil dereference occurs for rows without diagnostic data.
- [x] All custom diagnostic autocmds use a clear augroup.
- [x] `config/autotag.lua` and `nvconfig.lua` are removed only after reference checks pass.
- [x] README and CLAUDE describe the actual implementation and final keymap table.
- [x] Syntax, diagnostics smoke, reference search, and existing test pass.

## STOP conditions

Stop and report if:

- The custom diagnostics panel requires an unavailable optional integration to render.
- Existing user edits overlap the `<leader>xd` block; preserve them and report instead of overwriting.
- Either supposedly dead module has a caller outside the searched paths.
- The documentation search finds a legitimate reference that needs a different migration rather than deletion.

## Maintenance notes

- Any future diagnostics autocmd must use the existing clear augroup convention.
- If tiny-inline-diagnostic is re-enabled, decide whether it replaces this module before enabling both.
- Keep README keymaps synchronized when plugin-owned mappings move.
