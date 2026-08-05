# Plan 004: Prevent edit hooks from executing project-local formatter binaries

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- config/claude/hooks/format-on-edit.sh tests/shell/format-on-edit-test.bash`

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: MED
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: security
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

A globally configured post-edit hook must not execute code supplied by an untrusted checkout. The hook explicitly prefers `node_modules/.bin/biome` and can also use `npx --no-install`, which resolves project-local packages. Keep automatic formatting, but use only formatter commands from the trusted user PATH and reject `node_modules/.bin` results.

## Current state

`config/claude/hooks/format-on-edit.sh:57-87` prefers a local Biome binary and falls back to `npx --no-install prettier`. `format-on-edit.sh:118-121` executes the resulting array. The hook already uses command arrays, hashes before and after formatting, and returns structured jq output; preserve these contracts.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Syntax | `bash -n config/claude/hooks/format-on-edit.sh tests/shell/format-on-edit-test.bash` | exit 0 |
| Security regression | `bash tests/shell/format-on-edit-test.bash` | local fake binary is never run |
| Focused suite | `bash tests/shell/run.bash` | all pass |

## Scope

**In scope**: `config/claude/hooks/format-on-edit.sh`, `tests/shell/format-on-edit-test.bash`.

**Out of scope**: external Claude/Codex settings, adding trust databases, installing formatters, changing formatter flags, formatting unrelated files, and dependency files.

## Git workflow

Use the current branch. Preserve all existing work. Do not stage, commit, push, reset, clean, or create worktrees.

## Steps

### Step 1: Centralize trusted command resolution

Add a helper that resolves a command with `command -v`, rejects any path containing `/node_modules/.bin/`, and prints the trusted command path. Use it for Biome, Prettier, shfmt, and StyLua. Do not use `eval` or unquoted command strings.

**Verify**: `grep -nE 'npx|node_modules/.bin/biome' config/claude/hooks/format-on-edit.sh` → no executable fallback remains; only an intentional rejection check may mention `node_modules/.bin`.

### Step 2: Remove implicit local package execution

Remove explicit project-local Biome selection and all `npx --no-install` paths. Preserve the current extension-to-formatter mapping and the `FORMATTER_CMD` array. If no trusted formatter exists, exit 0 without modifying the file.

**Verify**: `bash -n config/claude/hooks/format-on-edit.sh` → exit 0.

### Step 3: Add hook trust-boundary tests

Create temporary checkout fixtures with a fake executable at `node_modules/.bin/biome` that writes an injection marker. Feed the hook valid PostToolUse JSON. Assert the marker is absent. Add a trusted fake Biome on PATH outside the checkout and assert it is called with `format --write FILE`. Also cover no formatter, formatter failure, and a filename with spaces.

**Verify**: `bash tests/shell/format-on-edit-test.bash` → all assertions pass.

## Test plan

Use only temporary files and fake executables. Do not invoke a real formatter or modify repository source during tests.

## Done criteria

- [ ] No project-local package executable is selected automatically.
- [ ] Formatter execution still uses an argument array.
- [ ] Trusted PATH formatter behavior remains functional.
- [ ] `bash tests/shell/run.bash` and `./bin/repo-check .` exit 0.
- [ ] Only in-scope files changed.

## STOP conditions

- Hook activation requires changing an external settings file.
- Tests execute a real formatter or project dependency.
- Preserving behavior requires an implicit local executable.
- Live code drifted from Current state.

## Maintenance notes

A future per-project trust feature needs explicit user approval and an owner-controlled allowlist. Do not reintroduce `npx`, `bunx`, or local package bins as automatic fallbacks.
