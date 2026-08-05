# Plan 009: Align installation and deployment documentation with Bunsen

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- README.md config/nvim/README.md tests/shell/docs-test.bash`

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: `plans/003-preserve-existing-zshrc.md`
- **Category**: docs
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

The README points to missing root TypeScript files, calls the active Node/Bun Bunsen config Deno-based, lists links absent from `dotfiles.config.ts`, and tells contributors to run the unsupported `bunsen sync`. The Neovim README also claims `bash install` creates its symlink. Documentation must describe the actual two-stage bootstrap without changing deployment behavior.

## Current state

- `README.md:180-245` documents missing `karabiner.config.ts`, `espanso.config.ts`, wrong `git/` paths, Deno, and links absent from the manifest.
- `README.md:465-471` says `bunsen sync`; Bunsen 0.0.9 supports `validate`, `status`, `apply`, and `diff`.
- `config/nvim/README.md:297-301` says `bash install` links Neovim.
- `install` creates directories, safely links only `.zshrc` after plan 003, and conditionally bootstraps mise.
- `dotfiles.config.ts:25-54` is the deployment source of truth for symlinks; Espanso and Karabiner are profile modules from `bunsen/`.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Bunsen commands | `./node_modules/.bin/bunsen --help` | includes validate/status/apply/diff; no sync |
| Documentation test | `bash tests/shell/docs-test.bash` | stale references absent |
| Cheap validation | `./node_modules/.bin/bunsen validate` | exit 0, no deployment mutation |

## Scope

**In scope**: `README.md`, `config/nvim/README.md`, `tests/shell/docs-test.bash`.

**Out of scope**: source/config behavior, generated symlinks, README redesign, screenshots, broad style edits, and `config/zsh/zshrc`.

## Git workflow

Use the current branch. Do not stage, commit, push, reset, clean, run `bunsen apply`, or modify deployed files.

## Steps

### Step 1: Correct the bootstrap sequence

Document: clone to `$HOME/dotfiles` as the default; run `bun install --frozen-lockfile`; run `bash install`; validate with `bunx bunsen validate`; inspect with `bunx bunsen diff`; apply only when intended with `bunx bunsen apply`. State that the installer refuses a conflicting `.zshrc`. Do not claim install applies all links.

**Verify**: `grep -n 'bunsen sync' README.md config/nvim/README.md` → no output.

### Step 2: Correct paths and deployment inventory

Replace missing root module paths with `bunsen/espanso.ts` and `bunsen/karabiner.ts`. Describe the configuration as TypeScript executed with Bun/Node-compatible imports. Make `dotfiles.config.ts` the canonical symlink inventory instead of maintaining an inaccurate long list. Correct `.gitconfig` to `config/git/gitconfig`; remove claims for undeployed `.editorconfig` and app links.

**Verify**: every backticked repository path introduced by this edit exists.

### Step 3: Correct Neovim setup text

State that Bunsen creates `~/.config/nvim`; `bash install` alone links only zshrc. Preserve the existing language-server and user documentation.

**Verify**: `bash tests/shell/docs-test.bash` → exit 0.

### Step 4: Add a small documentation drift check

Create a shell test that rejects `bunsen sync`, the two missing root config filenames, the wrong Git source, and the claim that `bash install` links Neovim. It must not parse arbitrary README prose or modify docs.

**Verify**: `./node_modules/.bin/bunsen validate && ./bin/repo-check .` → both exit 0.

## Test plan

The shell test checks only stable commands and paths. Use `test -e` for documented first-party paths where practical. Do not generate documentation from TypeScript in this plan.

## Done criteria

- [ ] Fresh-machine steps are complete and use supported commands.
- [ ] Deployment claims match `install` and `dotfiles.config.ts`.
- [ ] Neovim link ownership is correct.
- [ ] Documentation test, Bunsen validation, and repository check pass.
- [ ] Only in-scope files changed.

## STOP conditions

- Bunsen validation writes deployment state or requires network access.
- Plan 003 did not complete or installer behavior differs.
- Correct docs require changing deployment code.
- A documented path cannot be verified.

## Maintenance notes

Keep `dotfiles.config.ts` as the source of truth. When adding a symlink, update stable summary text only if it names that tool explicitly.
