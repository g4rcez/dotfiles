# Plan 005: Preserve complete paths in all worktree commands

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- bin/worktree tests/shell/worktree-test.bash`

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: MED
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: bug
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

`bin/worktree` parses the human display from `git worktree list` with whitespace-based awk fields. Repository and worktree paths containing spaces become truncated, and those paths feed removal, status, tmux, and directory navigation operations. Use Git's stable porcelain format and keep full paths as data.

## Current state

Whitespace parsing occurs at `bin/worktree:81-85,204-216,257,305-328,348-377`. Typical code is:

```bash
git worktree list | while read -r line; do
  wt_path="$(echo "$line" | awk '{print $1}')"
done
```

`cmd_mux` later extracts `selected_path` with `awk '{print $NF}'`, which also loses spaces. The script is Bash and uses quoted path arguments after parsing.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Syntax | `bash -n bin/worktree tests/shell/worktree-test.bash` | exit 0 |
| Regression | `bash tests/shell/worktree-test.bash` | paths with spaces remain exact |
| Focused suite | `bash tests/shell/run.bash` | all pass |

## Scope

**In scope**: `bin/worktree`, `tests/shell/worktree-test.bash`.

**Out of scope**: changing the worktree base layout, branch naming, tmux session naming, Git aliases, `bin/fzf-git`, zsh wrappers/completions, and actual removal of user worktrees.

## Git workflow

Use the current branch. Do not stage, commit, push, reset, clean, delete user worktrees, or create a project worktree.

## Steps

### Step 1: Add one porcelain parser

Replace every `git worktree list` human-output parser in this script with one shared parser based on `git worktree list --porcelain`. Emit path and branch as separate fields without trimming path whitespace. Prefer NUL-delimited internal data when practical; at minimum preserve spaces and tabs must not silently become path separators.

**Verify**: `grep -n "git worktree list |\|awk '{print \\$1}'\|awk '{print \\$NF}'" bin/worktree` → no worktree-path parsing matches.

### Step 2: Route every consumer through parsed records

Update list lines, prune, default `cd`, mux, overview, and `origin`. For fzf, place an opaque numeric record ID or another unambiguous field first; recover the path from the parser instead of reading the last display field. Preserve branch display and session-name behavior.

**Verify**: `bash -n bin/worktree` → exit 0.

### Step 3: Add real Git fixtures

Create temporary main and linked worktrees whose paths contain spaces. Exercise non-destructive public modes: default `cd`, list output, overview with `tmux` stubbed, and mux selection with `fzf`/`tmux` stubbed. Assert exact paths. Do not call prune or remove against the user's repository.

**Verify**: `bash tests/shell/worktree-test.bash` → all cases pass and fixture cleanup succeeds.

## Test plan

Cover main path with spaces, linked path with spaces, branch with slash, detached HEAD, and fzf selection. Use a local temporary Git repository with test identity configured only inside that fixture.

## Done criteria

- [ ] No consumer parses a worktree path from human-formatted output.
- [ ] Main and linked paths with spaces pass the regression test.
- [ ] Existing session-name transformation is unchanged.
- [ ] `bash tests/shell/run.bash` and `./bin/repo-check .` exit 0.
- [ ] Only in-scope files changed.

## STOP conditions

- Git on the host does not support `worktree list --porcelain`.
- A safe fix requires changing zsh wrappers or tmux configuration.
- A test would remove a non-fixture worktree.
- The script drifted from Current state.

## Maintenance notes

Treat porcelain fields as the contract and display strings as output only. Future fzf changes must never recover paths with positional whitespace fields.
