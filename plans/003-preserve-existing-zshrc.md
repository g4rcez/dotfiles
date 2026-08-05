# Plan 003: Preserve existing shell configuration during installation

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- install tests/shell/install-test.bash`

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: migration
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

The installer currently uses `ln -sf` for `~/.zshrc`. Running it can delete an existing regular file or replace a symlink to another configuration. Installation must be idempotent for the intended link and must refuse conflicting destinations without changing them.

## Current state

`install:17-19`:

```bash
mkdir -p "$HOME/.tmp"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/zsh/zshrc" "$HOME/.zshrc"
```

The installer uses Bash with `set -euo pipefail` and derives `DOTFILES_DIR` through `bin/lib/dotfiles-shell.sh`. Do not make a bin-only navigation change or alter the repository-root contract.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Syntax | `bash -n install tests/shell/install-test.bash` | exit 0 |
| Regression | `bash tests/shell/install-test.bash` | all fixture cases pass |
| Focused suite | `bash tests/shell/run.bash` | all pass |

## Scope

**In scope**: `install`, `tests/shell/install-test.bash`.

**Out of scope**: mise bootstrap commands, curl bootstrap integrity, Bunsen behavior, other symlinks, automatic migration or deletion, and `config/zsh/zshrc`.

## Git workflow

Stay on the current branch. Do not stage, commit, push, clean, reset, or alter pre-existing files.

## Steps

### Step 1: Add a safe zshrc-link function

Replace `ln -sf` with explicit behavior:

1. If `~/.zshrc` does not exist, create the symlink.
2. If it is already a symlink that resolves to this checkout's `config/zsh/zshrc`, report it as already configured and succeed.
3. If it is a regular file, directory, broken symlink, or different symlink, print a clear error and exit nonzero without changing it.

Do not add an implicit backup name because repeated runs can overwrite backups. Do not add a force option in this plan.

**Verify**: `bash -n install` → exit 0.

### Step 2: Add isolated installer fixtures

Create a shell test with a temporary `HOME` and a fake executable `mise` early in `PATH`, so the installer never uses the network. Test absent destination, correct symlink, regular file with sentinel content, different symlink, and broken symlink. Assert conflicts remain byte-for-byte or link-for-link unchanged.

**Verify**: `bash tests/shell/install-test.bash` → all cases pass without network access.

## Test plan

Use the plan 001 shell helper. Every fixture must set `DOTFILES_DIR` to the real checkout and restore temporary environment variables through a subshell.

## Done criteria

- [ ] Existing `.zshrc` files and conflicting symlinks are never replaced.
- [ ] A missing destination gets the intended symlink.
- [ ] Re-running against the intended symlink exits 0.
- [ ] `bash tests/shell/run.bash` and `./bin/repo-check .` exit 0.
- [ ] Only in-scope files changed.

## STOP conditions

- Testing starts a network request or real mise installation.
- Safe behavior requires modifying another deployment file.
- The installer has drifted from Current state.
- A conflict cannot be distinguished without following and modifying its target.

## Maintenance notes

The README correction is plan 009 and depends on this behavior. Future overwrite support must require an explicit user option and a non-destructive backup contract.
