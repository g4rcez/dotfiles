# Plan 005: Add a lightweight Neovim configuration smoke test

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report — do not improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 9e0ca10..HEAD -- tests lua/config lua/plugins init.lua`

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: 001-runtime-integrations.md, 002-lsp-toolchain-policy.md, 003-keymaps-and-mini.md, 004-diagnostics-cleanup-docs.md
- **Category**: tests
- **Status**: Complete
- **Planned at**: commit `9e0ca10`, 2026-09-14

## Why this matters

The only current test covers contextual completion. Startup, lazy integrations, diagnostics, keymap ownership, and VS Code gating can regress while the configuration still parses. A small headless test keeps verification fast and uses the repository's existing plain-Neovim test style; it does not add a test framework.

## Current state

- `tests/contextual_completion.lua` is a standalone Neovim script that exits nonzero on failure.
- There is no startup smoke script for normal mode or `vim.g.vscode` mode.
- Lazy integrations are only exercised manually.

## Commands you will need

| Purpose | Command | Expected on success |
| --- | --- | --- |
| Normal smoke | `nvim --headless -u init.lua -l tests/smoke.lua` | Prints `nvim smoke: PASS` and exits 0 |
| VS Code smoke | `nvim --headless --cmd 'let g:vscode=1' -u init.lua -l tests/smoke.lua` | Prints `nvim smoke: PASS` and exits 0 |
| Existing test | `nvim --headless -u NONE -l tests/contextual_completion.lua` | Prints `contextual_completion: PASS` |
| Syntax | `nvim --headless -u NONE -c 'lua local n=0; for _,f in ipairs(vim.fn.glob("lua/**/*.lua",false,true)) do local c,e=loadfile(f); if not c then print(f,e); n=n+1 end end; if n>0 then vim.cmd("cquit 1") end' -c 'qa!'` | Exit 0 |

## Scope

**In scope**:

- `tests/smoke.lua` (create)

**Out of scope**:

- Any production configuration change; fixes belong in Plans 001-004.
- A new test framework, package, or lockfile.
- Network-dependent plugin updates or full end-to-end tests.

## Git workflow

- Run `git diff --cached --quiet --` before implementation; stop if staged changes exist.
- Preserve all unstaged and untracked work. Do not reset, clean, stage, or commit.

## Steps

### Step 1: Add deterministic smoke assertions

Create `tests/smoke.lua` using the existing script style. Assert:

- `vim.lsp.config` and `vim.lsp.enable` exist.
- `require("config.markdown_viewer").image_dir()` returns a string in a temporary or current test buffer without exposing secrets.
- `require("config.diagnostics").setup` exists.
- The normal configuration can force-load DAP and `pcall(require("dapui").toggle)` succeeds; close the UI afterward.
- Runtimepath contains exactly one `lua/mini/pairs.lua` and one `lua/mini/bracketed.lua`.
- The final keymap ownership assertions from Plan 003 hold for the native mode.

Avoid assertions on installed external language servers; those are covered by Plan 002's temporary fixtures.

**Verify**: `nvim --headless -u init.lua -l tests/smoke.lua` → prints `nvim smoke: PASS` and exits 0.

### Step 2: Support VS Code mode without false failures

When `vim.g.vscode` is set, skip assertions for native-only DAP, custom diagnostics UI, and Snacks/Mini plugin mappings that are intentionally disabled. Still assert that startup succeeds, local modules parse, and no duplicate Mini runtime paths exist. Do not change production gating to satisfy the test.

**Verify**: `nvim --headless --cmd 'let g:vscode=1' -u init.lua -l tests/smoke.lua` → prints `nvim smoke: PASS` and exits 0.

### Step 3: Run the complete lightweight check set

Run both smoke commands, the existing contextual completion test, and the syntax command. Do not run plugin updates or a full network-dependent suite.

**Verify**: all four commands exit 0.

## Test plan

- Normal startup: integrations and ownership table.
- VS Code startup: intentional native-plugin gating.
- Existing contextual completion regression test.
- Lua syntax for all configuration files.

## Done criteria

- [x] `tests/smoke.lua` exists and uses no new framework or dependency.
- [x] Normal smoke passes.
- [x] VS Code smoke passes.
- [x] Existing contextual test passes.
- [x] Syntax check passes.
- [x] No production files are modified by this plan.

## STOP conditions

Stop and report if:

- A smoke assertion requires a network service or an external server not already present.
- VS Code mode loads a plugin that the production configuration explicitly intends to disable; report the plugin and do not weaken the assertion.
- The final keymap ownership differs from Plan 003; update the plan status and report rather than accepting load-order behavior.

## Maintenance notes

- Add a smoke assertion whenever a new custom module is wired into `init.lua`.
- Keep fixture-dependent LSP tests separate from this deterministic startup test.
- Run both modes after changing `plugins/vscode.lua` or any `cond` expression.
