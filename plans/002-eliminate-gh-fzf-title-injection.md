# Plan 002: Eliminate pull-request title injection from `gh-fzf`

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- bin/gh-fzf tests/shell/gh-fzf-test.bash`

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: security
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

`gh-fzf` places a remotely controlled PR title inside nested shell and jq quoting. A crafted title can leave the jq expression and execute a shell command when the row is previewed or selected. Only the numeric PR number must cross into fzf action commands.

## Current state

`bin/gh-fzf:14-18`:

```bash
jq -c '.[] | .title' "$FZF_GITCLI_FILE" \
  | fzf --ansi --info inline \
  --preview "jq -c -r '.[] | select(.title | contains(\"{}\"))|.body' \"\$FZF_GITCLI_FILE\" ..." \
  --bind "enter:become(jq -c -r '.[] | select(.title | contains(\"{}\")) | .number' ... | xargs -n 1 gh pr checkout)"
```

The script already uses a secure `mktemp` file, `set -euo pipefail`, arrays are not needed, and `gh pr list` returns a numeric `.number` field.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Syntax | `bash -n bin/gh-fzf tests/shell/gh-fzf-test.bash` | exit 0 |
| Regression | `bash tests/shell/gh-fzf-test.bash` | malicious title is data only |
| Focused suite | `bash tests/shell/run.bash` | all pass |

## Scope

**In scope**: `bin/gh-fzf`, `tests/shell/gh-fzf-test.bash`.

**Out of scope**: other fzf helpers, GitHub authentication, changing checkout behavior, dependency changes, and `config/zsh/zshrc`.

## Git workflow

Use the current branch. Preserve existing changes. Do not stage, commit, push, clean, reset, or create a worktree.

## Steps

### Step 1: Make the numeric PR number the record key

Render each fzf row as `number<TAB>title`. Configure `--delimiter` and `--with-nth` so users see the title while `{1}` remains the numeric key. Do not interpolate title placeholders into any action string.

**Verify**: `grep -n 'contains.*{}' bin/gh-fzf` → no output.

### Step 2: Add a numeric preview subcommand

Add an internal `--preview NUMBER` mode. Validate `NUMBER` with `^[0-9]+$`, then select the body with `jq --argjson number "$number"`. Use `$0 --preview {1}` for fzf preview. Use `gh pr checkout {1}` directly for Enter. Do not use `eval`, `xargs`, nested title matching, or `bash -c`.

**Verify**: `bash -n bin/gh-fzf` → exit 0.

### Step 3: Add the injection regression

Create a shell test that stubs `gh` and `fzf`, supplies a PR title containing quotes, semicolons, command substitution, and a unique injection marker, then confirms:

- the marker appears only in fzf stdin display data;
- no marker appears in preview/bind command arguments;
- the action arguments contain `{1}` and never `{}`;
- preview rejects a nonnumeric ID.

Use `tests/shell/test-helper.bash` from plan 001.

**Verify**: `bash tests/shell/gh-fzf-test.bash` → exit 0 and no injected marker output.

## Test plan

Cover a normal title, duplicate titles with different numbers, a malicious title, empty PR list, numeric preview, and rejected nonnumeric preview.

## Done criteria

- [ ] No title placeholder occurs inside a command string.
- [ ] Only numeric PR IDs reach preview and checkout actions.
- [ ] `bash tests/shell/run.bash` exits 0.
- [ ] `./bin/repo-check .` exits 0.
- [ ] Only in-scope files changed relative to baseline.

## STOP conditions

- The installed fzf cannot select fields by numeric delimiter.
- Secure behavior requires changing another fzf helper.
- A test would need live GitHub access.
- The live script no longer matches Current state.

## Maintenance notes

Future fields can be added after the visible title, but action commands must continue to use the numeric first field. Review every fzf placeholder as command input, not display text.
