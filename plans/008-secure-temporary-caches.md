# Plan 008: Constrain dictionary and workflow cache files

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- bin/cambridge-cli bin/workflows tests/espanso/cambridge-cache.test.ts tests/shell/workflows-cache-test.bash`

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: security
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

`cambridge-cli` uses a shared `/tmp/cambridge` directory and derives filenames from input while replacing whitespace only. `bin/workflows` truncates a predictable `/tmp/gh-workflows-${UID}.json`, which follows a pre-created symlink. Use private XDG cache directories, non-path-derived dictionary keys, and securely created per-process workflow files.

## Current state

`bin/cambridge-cli:6-16`:

```ts
const CACHE_DIR = "/tmp/cambridge";
mkdirSync(CACHE_DIR, { recursive: true });
return join(CACHE_DIR, `${word.toLowerCase().replace(/\s+/g, "-")}.md`);
```

`bin/workflows:4-9`:

```bash
CACHE="/tmp/gh-workflows-${UID}.json"
...
jq ... > "$CACHE"
```

Use XDG paths and secure temporary-file patterns already used by `bin/gh-fzf`.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Type test | `bun test tests/espanso/cambridge-cache.test.ts` | cache paths stay below fixture root |
| Shell test | `bash tests/shell/workflows-cache-test.bash` | unique private cache and cleanup pass |
| Syntax | `bash -n bin/workflows tests/shell/workflows-cache-test.bash` | exit 0 |
| Repository check | `./bin/repo-check .` | exit 0 |

## Scope

**In scope**:

- `bin/cambridge-cli`
- `bin/workflows`
- `tests/espanso/cambridge-cache.test.ts` (create)
- `tests/shell/workflows-cache-test.bash` (create)

**Out of scope**: Cambridge network parsing, audio playback, GitHub workflow behavior, cache migration, dependencies, and other `/tmp` users.

## Git workflow

Use the current branch. Preserve all user files. Do not stage, commit, push, reset, clean, or write tests into shared `/tmp` paths outside securely created fixtures.

## Steps

### Step 1: Move Cambridge cache to a private XDG directory

Use `${XDG_CACHE_HOME:-$HOME/.cache}/cambridge`, create it with mode `0700`, and write files with mode `0600`. Derive the filename from a stable SHA-256 hash of normalized input plus `.md`, not raw input. Export the path helper for testing and guard `main()` with `import.meta.main` so import has no network or CLI side effect. Ensure the resolved file always remains directly below the cache root.

**Verify**: `bun test tests/espanso/cambridge-cache.test.ts` → traversal strings and normal words stay under the fixture cache.

### Step 2: Use a secure workflow cache lifecycle

Create `${XDG_CACHE_HOME:-$HOME/.cache}/gh-workflows` with `0700`, then use `mktemp` for one JSON file. Export its path so fzf preview/reload subprocesses share it. Create it only in the interactive main flow, clean it with a trap, require it for internal subcommands, and never use a fixed `/tmp` filename. Keep jq writes quoted and within the private directory.

**Verify**: `bash -n bin/workflows` → exit 0.

### Step 3: Add filesystem safety regressions

Bun tests must cover `../`, absolute-looking text, slashes, spaces, case normalization, stable keys, directory mode where supported, and import without execution. Shell tests must stub `gh` and `fzf`, assert the cache is inside the temporary XDG root, has a unique name, is shared with preview, and is removed on exit.

**Verify**: both focused test commands pass.

## Test plan

No live Cambridge or GitHub request is allowed. Use fake command output and temporary XDG roots. Do not assert platform-specific permission bits on filesystems that do not expose POSIX modes; gate that assertion.

## Done criteria

- [ ] No fixed `/tmp/cambridge` or `/tmp/gh-workflows-*` path remains.
- [ ] User input cannot become a path segment.
- [ ] Workflow cache creation is secure and cleanup is automatic.
- [ ] Focused tests and repository check pass.
- [ ] Only in-scope files changed.

## STOP conditions

- Testing requires network access.
- fzf subprocesses do not inherit the exported cache path.
- A safe change requires a new dependency.
- Existing cache compatibility is a required product behavior.

## Maintenance notes

Future shared state must use XDG cache/state directories according to persistence needs. Never create predictable writable files directly under a shared temporary directory.
