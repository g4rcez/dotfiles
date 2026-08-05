# Plan 007: Keep Context Lite diagnostics stable for large histories

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- bin/context-lite-doctor tests/shell/context-lite-doctor-test.bash`

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: bug
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

The doctor runs `find | sort | head` under `set -o pipefail`. When the history is large, `head` closes the pipe and `sort` exits on SIGPIPE, so the command terminates with status 141 before printing diagnostics. The bounded sample must not stop an upstream process early.

## Current state

`bin/context-lite-doctor:58-60`:

```bash
find "$runs_dir" -type f -name output.txt -mtime "-$days" -print 2>/dev/null |
  sort -r | head -n "$sample" >"$tmp_files"
```

The script already supports `--pi-dir`, `--sample`, and `--no-record`, which permit isolated tests. Its output includes `run outputs sampled:`.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Syntax | `bash -n bin/context-lite-doctor tests/shell/context-lite-doctor-test.bash` | exit 0 |
| Regression | `bash tests/shell/context-lite-doctor-test.bash` | large fixture exits 0 |
| Repository check | `./bin/repo-check .` | exit 0 |

## Scope

**In scope**: `bin/context-lite-doctor`, `tests/shell/context-lite-doctor-test.bash`.

**Out of scope**: changing classification patterns, SQLite queries, history format, output text, retention policy, or Pi data.

## Git workflow

Use the current branch. Do not stage, commit, push, reset, clean, or access real Pi run content in tests.

## Steps

### Step 1: Replace the early-closing limiter

Keep reverse sorting and the sample limit, but use a consumer that reads the complete sorted stream, such as `awk -v limit="$sample" 'NR <= limit'`. Do not hide pipeline failures with a broad `|| true`, and do not disable `pipefail`.

**Verify**: `bash -n bin/context-lite-doctor` → exit 0.

### Step 2: Add bounded-history fixtures

Create more files than the pipe buffer normally holds under a temporary `PI_DIR`. Run with `--sample 1 --no-record`. Assert exit 0, exactly one sampled output, no stored content in stdout, and no history file. Also test invalid sample, missing Pi directory, and a small failure-classification fixture.

**Verify**: `bash tests/shell/context-lite-doctor-test.bash` → all cases pass.

## Test plan

Use generated short metadata-shaped output only. Do not read `~/.pi`. Ensure fixture creation is fast and deterministic; a few thousand tiny files is acceptable only inside the temporary directory.

## Done criteria

- [ ] Large fixture exits 0 rather than 141.
- [ ] Sample count remains bounded.
- [ ] `pipefail` remains enabled.
- [ ] No real stored output is printed.
- [ ] Shell suite and repository check pass.
- [ ] Only in-scope files changed.

## STOP conditions

- The reproduction requires real user Pi data.
- The fix changes classification or persistence semantics.
- A full sort is proven to be the primary performance problem and requires a redesign.
- In-scope code drifted.

## Maintenance notes

Any future pipeline that bounds output under `pipefail` must consume upstream input fully or handle the specific SIGPIPE status without hiding real errors.
