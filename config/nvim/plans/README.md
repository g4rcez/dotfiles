# Neovim improvement plans

These plans turn the read-only audit at commit `9e0ca10` into small, sequential implementation tasks. They are implementation plans, not completed work. The working tree already contained unrelated modified and untracked files when the audit started; each plan requires a staged-change check and preservation of that work.

## Status

| Plan | Priority | Depends on | Status |
| --- | --- | --- | --- |
| [001 — Runtime integrations](001-runtime-integrations.md) | P1 | — | Complete |
| [002 — LSP/toolchain policy](002-lsp-toolchain-policy.md) | P1 | — | Complete |
| [003 — Keymaps and Mini](003-keymaps-and-mini.md) | P1 | — | Complete |
| [004 — Diagnostics, cleanup, docs](004-diagnostics-cleanup-docs.md) | P2 | 003 | Complete |
| [005 — Smoke tests](005-smoke-tests.md) | P2 | 001–004 | Complete |

## Execution order

1. Run 001 and 002 in parallel only if their drift checks show no overlap with active work.
2. Run 003 after the first two plans, because it consolidates plugin and LSP mapping ownership.
3. Run 004 after 003, because it owns the diagnostics mapping handoff and documentation table.
4. Run 005 last, because it asserts the final integrations, runtime paths, and keymap ownership.

Each plan contains its own scope, current-state evidence, verification commands, done criteria, and stop conditions. Do not mark a plan complete until its commands pass and its status row is updated here.

## Scope summary

- Fix the missing Markdown image-directory module and configure DAP UI.
- Make ESLint/Oxlint project-aware with deterministic Oxlint precedence.
- Align Conform/nvim-lint tools with one Mason tool list.
- Resolve competing mappings and document ownership.
- Remove duplicate Mini distributions.
- Activate and harden custom diagnostics.
- Remove only verified dead local modules.
- Update stale documentation.
- Add plain headless normal/VS Code smoke coverage without a new test framework.

## Shared constraints

- No dependency, lockfile, schema, authentication, public API, or production-data changes.
- No clipboard/AppleScript changes; that finding was explicitly skipped.
- No plugin updates, network installs, destructive Git commands, staging, or commits.
- Preserve existing user modifications and stop on drift in an in-scope block.
- Use the smallest focused verification first, then the broader lightweight checks in Plan 005.
