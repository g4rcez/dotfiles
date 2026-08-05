# Plan 006: Make Espanso color conversion correct and type-safe

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- espanso/scripts/colors.ts tests/espanso/colors.test.ts`

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: MED
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: bug
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

The color script treats every `color-convert` result as an array. Hex conversions return a string, so RGB red becomes `F` instead of `FF0000`. The HSL parser also requires alpha and rejects standard CSS HSL. Correct parsing and result formatting must be explicit and covered through the same CLI that Espanso uses.

## Current state

- `espanso/main.ts` dynamically loads `espanso/scripts/<mode>.ts` and passes `--mode` and `--value`.
- `espanso/scripts/colors.ts:19-21` uses regexes; HSL requires alpha.
- `colors.ts:33-61` declares `string[]`, but `convert.*.hex()` returns a scalar string.
- `colors.ts:64-70` indexes every result as `color[0..2]`.
- Current LSP diagnostics report TS7053 at conversion indexes and TS2345 at formatter arguments.
- Match four-space TypeScript formatting and avoid `any`.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Regression | `bun test tests/espanso/colors.test.ts` | all cases pass |
| LSP/typecheck | `bunx --bun tsc --noEmit --pretty false` | no diagnostics from `espanso/scripts/colors.ts`; unrelated existing errors may remain |
| Repository check | `./bin/repo-check .` | exit 0 |

## Scope

**In scope**: `espanso/scripts/colors.ts`, `tests/espanso/colors.test.ts` (create).

**Out of scope**: other Espanso scripts, changing trigger configuration, adding a color library, alpha-channel preservation beyond the current output contract, and dependency files.

## Git workflow

Use the current branch. Preserve all current work. Do not stage, commit, push, reset, clean, or create a worktree.

## Steps

### Step 1: Parse supported input shapes explicitly

Represent identified source modes as a closed union. Parse:

- `#RGB`, `#RRGGBB`, and forms already accepted by `color-convert`;
- `rgb(r,g,b)` and `rgba(r,g,b,a)` with optional whitespace;
- `hsl(h,s%,l%)` and `hsla(h,s%,l%,a)` with optional whitespace.

Validate numeric captures before conversion. Keep current output alpha fixed at `1`; do not silently claim input alpha was preserved.

**Verify**: LSP diagnostics for `espanso/scripts/colors.ts` → no errors.

### Step 2: Separate scalar and tuple conversion results

For `hex`, treat the result as one complete scalar string. For `rgb` and `hsl`, require a three-number tuple before formatting. Same-mode conversion must parse and reformat components rather than place a complete CSS string in tuple index zero. Make conversion mode a key of the formatter map throughout; do not use a free `string` index or `any`.

**Verify**: `bun espanso/main.ts colors --mode hex --value 'rgb(255, 0, 0)'` → exactly `FF0000`.

### Step 3: Add CLI-level regression tests

Create Bun tests that spawn `bun espanso/main.ts colors`. Cover RGB→hex, standard HSL→hex, hex→RGB, hex→HSL, same-mode RGB/HSL/hex, optional alpha syntax, whitespace, and invalid input/mode behavior. Assert complete output, not substrings.

**Verify**: `bun test tests/espanso/colors.test.ts` → all tests pass.

## Test plan

Required expectations include red as `FF0000`, `hsl(0,100%,50%)` as `FF0000`, and hex red as `rgba(255, 0, 0, 1)` for RGB mode. Preserve the repository's current formatter spelling unless tests prove an intentional existing contract differs.

## Done criteria

- [ ] RGB→hex never truncates a scalar result.
- [ ] Three-component HSL is accepted.
- [ ] Same-mode conversions return valid complete values.
- [ ] No TypeScript diagnostic remains in `colors.ts`.
- [ ] Bun test and repository check pass.
- [ ] Only in-scope files changed.

## STOP conditions

- Existing Espanso configuration expects a different output shape than the current formatters show.
- Correct behavior requires changing `espanso/main.ts` or a dependency.
- A conversion rule cannot be specified without a product decision.
- In-scope code drifted from Current state.

## Maintenance notes

If alpha preservation becomes required, add it as a separate contract change with tests. Keep scalar-returning and tuple-returning `color-convert` APIs visibly separate.
