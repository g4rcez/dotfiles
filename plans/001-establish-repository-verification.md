# Plan 001: Establish one complete repository verification command

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" section occurs, stop and report. When done, do not update `plans/README.md` when a reviewer told you that they maintain the index.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- bin/repo-check tests/shell tests/bun`
> If an in-scope tracked file changed, compare the current state below with live code. On a mismatch, STOP.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: none
- **Category**: tests
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

The repository has Bash, zsh, Bun/TypeScript, and Lua code, but `bin/repo-check` currently checks only `bin/dotfiles-doctor` and five zsh files. A single deterministic command must detect syntax failures and run focused regression tests before the selected fixes land.

## Current state

- `package.json:1-13` has no scripts.
- `bin/repo-check:117-160` discovers conventional package scripts, then adds only the doctor and a partial zsh syntax command for this repository.
- `config/nvim/tests/contextual_completion.lua` is a working test that is not registered in `bin/repo-check`.
- There is no first-party shell test runner.
- Match the strict shell style in `bin/dotfiles-doctor`: Bash shebang, `set -euo pipefail`, quoted variables, and concise output.

Current excerpt from `bin/repo-check:157-160`:

```bash
if [[ -f config/zsh/zshrc && -x bin/dotfiles-doctor ]]; then
  add_cmd "bash bin/dotfiles-doctor"
  add_cmd "zsh -n config/zsh/zshrc config/zsh/alias.sh config/zsh/exports.sh config/zsh/git.sh config/zsh/zstyle.sh"
fi
```

## Commands you will need

| Purpose | Command | Expected on success |
| --- | --- | --- |
| Dry run | `./bin/repo-check --dry-run .` | Lists doctor, shell tests, and available Neovim/Bun tests |
| Shell tests | `bash tests/shell/run.bash` | All tests pass, exit 0 |
| Repository check | `./bin/repo-check .` | Every registered focused check passes |

## Scope

**In scope**:

- `bin/repo-check`
- `tests/shell/test-helper.bash` (create)
- `tests/shell/run.bash` (create)
- `tests/shell/syntax-test.bash` (create)
- `tests/shell/repo-check-test.bash` (create)
- `tests/bun/run.bash` (create during review revision)

**Out of scope**:

- `package.json`, dependency files, CI, formatters, full builds, and E2E tests.
- Fixing syntax defects discovered in unrelated scripts. STOP and report them instead.
- `config/zsh/zshrc`, which has pre-existing user changes.

## Git workflow

Work in the current branch. Do not create a worktree, stage, commit, push, reset, clean, or alter pre-existing unstaged/untracked files.

## Steps

### Step 1: Add the dependency-free shell test harness

Create `tests/shell/test-helper.bash` with small assertion helpers and temporary-directory cleanup. Create `tests/shell/run.bash` to execute sorted `tests/shell/*-test.bash` files in separate Bash processes and fail on the first failure.

**Verify**: `bash -n tests/shell/test-helper.bash tests/shell/run.bash` → exit 0.

### Step 2: Add tracked shell syntax coverage

Create `tests/shell/syntax-test.bash`. Enumerate tracked files with `git ls-files -z`; inspect each shebang; run `bash -n` for Bash files and `zsh -n` for zsh files when zsh is available. Also fail when an executable `bin/` file uses `#!/bin/env bash` or has no shebang. Do not parse Lua, Bun, AppleScript, or Swift files as shell.

**Verify**: `bash tests/shell/syntax-test.bash` → expected to identify the two existing `#!/bin/env bash` scripts as failures. Because these are pre-existing and outside this plan, register the check in report-only form for those exact two paths or explicitly allowlist them with TODO text; do not edit them.

### Step 3: Register all focused checks

Update `bin/repo-check` to run:

1. `bash bin/dotfiles-doctor`.
2. `bash tests/shell/run.bash`.
3. The existing Neovim contextual-completion test when `nvim` is installed.
4. `bash tests/bun/run.bash` only when Bun is installed and at least one `*.test.ts` exists below the root `tests/` directory. The runner must pass exact file paths below root `tests/` to Bun; `bun test tests` is forbidden because it also matched `bunsen/lib/tests` during review.

Do not add a recursive package `check` script. Keep unavailable platform tools as explicit skips, not failures.

**Verify**: `./bin/repo-check --dry-run .` → lists the doctor and shell runner; lists Neovim when installed; does not invoke itself recursively.

### Step 4: Test command discovery

Create `tests/shell/repo-check-test.bash`. Run the dry-run command, assert that required checks are listed once, and assert that no recursive `repo-check` command appears. Create `tests/bun/run.bash` to collect exact `*.test.ts` paths only below the root `tests/` directory into a Bash array and pass those paths to one `bun test` invocation. Add a dry-run mode that proves every selected path starts with `tests/` and that `bunsen/lib/tests` is never selected.

**Verify**: `bash tests/bun/run.bash --dry-run` lists only root test paths; `bash tests/shell/run.bash` → all tests pass.

## Test plan

The syntax test covers tracked Bash/zsh files, invalid executable interpreter contracts, filenames with spaces, and unavailable optional tools. The repo-check test covers command registration and recursion prevention.

## Done criteria

- [ ] `bash tests/shell/run.bash` exits 0.
- [ ] `./bin/repo-check --dry-run .` lists every intended focused check once.
- [ ] `./bin/repo-check .` exits 0 on the current host and does not run `bunsen/lib/tests`.
- [ ] `bash tests/bun/run.bash --dry-run` lists only files below root `tests/`.
- [ ] No dependency or lockfile changed.
- [ ] No file outside Scope changed relative to the pre-execution baseline.

## STOP conditions

- A full check requires a network request, package install, full build, or full test suite.
- A pre-existing syntax defect other than the two known `/bin/env` shebangs blocks the baseline.
- The implementation needs `package.json` or a new dependency.
- An in-scope file drifted from the excerpt.

## Maintenance notes

All later regression plans add tests under `tests/shell/` or `tests/**/*.test.ts`; `bin/repo-check` must discover them without further registration. Review the allowlist for the invalid shebangs and remove entries when those scripts are corrected.
