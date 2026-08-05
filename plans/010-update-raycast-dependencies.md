# Plan 010: Update vulnerable Raycast dependency trees

> **Executor instructions**: Follow each step and verification. STOP instead of improvising.
>
> **Drift check (run first)**: `git diff --stat b7802a2..HEAD -- raycast/snippets/package.json raycast/snippets/pnpm-lock.yaml raycast/snippets/pnpm-workspace.yaml raycast/snippets/src/snippets.tsx raycast/whichkey/package.json raycast/whichkey/pnpm-lock.yaml raycast/whichkey/pnpm-workspace.yaml raycast/whichkey/src/whichkey.tsx`

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: MED
- **Depends on**: `plans/001-establish-repository-verification.md`
- **Category**: migration
- **Planned at**: commit `b7802a2`, 2026-08-05

## Why this matters

Both Raycast extensions pin `@raycast/api` 1.88.4 and `@raycast/utils` 1.17.0. Their production dependency audits report many high-severity advisories in build/distribution dependency paths. Update the two Raycast packages together, regenerate only their lockfiles, and make only source migrations required by current types.

## Current state

- `raycast/snippets/package.json:21-29` and `raycast/whichkey/package.json:20-28` pin the same old Raycast packages.
- Both lockfiles resolve `@raycast/api@1.88.4`.
- On 2026-08-05, `pnpm outdated` reported exact current releases `@raycast/api@1.104.24` and `@raycast/utils@2.2.7`.
- `snippets.tsx` imports `Action`, `ActionPanel`, `Detail`, and `List`; `whichkey.tsx` imports `Detail` and `List`.
- User approval covers these manifest and lockfile updates. Lifecycle scripts must remain disabled during install.

## Commands you will need

| Purpose | Command | Expected |
| --- | --- | --- |
| Update each extension | `pnpm add --save-exact --ignore-scripts @raycast/api@1.104.24 @raycast/utils@2.2.7` | manifest and local lock update only |
| Typecheck | `pnpm exec tsc --noEmit` | exit 0 in each extension |
| Lint | `pnpm lint` | exit 0 in each extension |
| Audit | `pnpm audit --prod` | no high or critical advisory in each extension |
| Production override fix | `npm_config_ignore_scripts=true pnpm audit --fix=override --prod` | adds reviewed `pnpm.overrides`; no lifecycle scripts |

## Scope

**In scope**:

- `raycast/snippets/package.json`
- `raycast/snippets/pnpm-lock.yaml`
- `raycast/snippets/pnpm-workspace.yaml` (created by pnpm 11 to hold security overrides)
- `raycast/snippets/src/snippets.tsx` only if required by type errors
- `raycast/whichkey/package.json`
- `raycast/whichkey/pnpm-lock.yaml`
- `raycast/whichkey/pnpm-workspace.yaml` (created by pnpm 11 to hold security overrides)
- `raycast/whichkey/src/whichkey.tsx` only if required by type errors

**Out of scope**: root package/lockfile, unrelated dev dependency upgrades, formatting migrations, publishing, Raycast Store actions, full `ray build`, and other extension features.

## Git workflow

Use the current branch. Do not stage, commit, push, reset, clean, publish, or create a worktree. Preserve all existing files.

## Steps

### Step 1: Confirm registry targets and baseline

Run `pnpm outdated --format json` and `pnpm audit --prod` in each extension. Confirm the target versions still exist and record baseline audit counts. If newer versions now exist, continue with the exact planned versions; do not chase latest without plan refresh.

**Verify**: registry output identifies both exact targets.

### Step 2: Update snippets with scripts disabled

From `raycast/snippets`, run the exact update command. Inspect the manifest and lockfile diff. No lifecycle script may run. Do not update unrelated direct dependencies.

**Verify**: `pnpm exec tsc --noEmit && pnpm lint` → both exit 0. If a Raycast API type changed, make the smallest required edit only in `src/snippets.tsx` and rerun.

### Step 3: Update whichkey with scripts disabled

Repeat in `raycast/whichkey`.

**Verify**: `pnpm exec tsc --noEmit && pnpm lint` → both exit 0. If needed, make the smallest API migration only in `src/whichkey.tsx`.

### Step 4: Patch vulnerable production transitives with reviewed overrides

Review discovered a false assumption: API 1.104.24 and utils 2.2.7 still resolve vulnerable production versions of `brace-expansion`, `js-yaml`, `minimatch`, and `picomatch`. In each extension run `npm_config_ignore_scripts=true pnpm audit --fix=override --prod`. pnpm 11 stores these overrides in a local `pnpm-workspace.yaml`; that file is intentional scope. Inspect every generated override against the audit's patched-version range. Then run `pnpm install --ignore-scripts` to apply the overrides to the lockfile. Keep only production transitive overrides created by pnpm; do not hand-select unrelated upgrades or ignore advisories.

**Verify**: `pnpm audit --prod` reports no high or critical advisory in each extension; typecheck still exits 0.

### Step 5: Inspect lock scope and document pre-existing lint failures

Check Git diff to ensure root `bun.lockb` and other manifests did not change. `pnpm lint` currently fails on pre-existing package description/title validation, an invalid extension icon, and source formatting. Record this as skipped pre-existing validation; do not edit the icon, descriptions, titles, or source formatting in this security plan.

**Verify**: `git diff --name-only` for this plan lists only in-scope manifest and lockfile paths unless a type-required source migration was necessary.

## Test plan

Typecheck and lint both small extension sources. Do not run full Raycast builds without separate human approval because builds are environment-dependent. Record that skipped validation in the final report.

## Done criteria

- [ ] Both manifests pin API 1.104.24 and utils 2.2.7 exactly.
- [ ] Both lockfiles and local `pnpm-workspace.yaml` override files are generated by pnpm with lifecycle scripts disabled.
- [ ] Both typechecks pass.
- [ ] Both lints are either passing or explicitly recorded as the same pre-existing validation/icon/format failures; this plan does not fix them.
- [ ] Both production audits contain no high or critical findings after reviewed pnpm overrides.
- [ ] Root package and lockfile are unchanged.
- [ ] Only in-scope files changed.

## STOP conditions

- A target version is unavailable or has a new known high/critical advisory.
- Install attempts to run lifecycle scripts.
- Passing typecheck requires unrelated dependency upgrades or broad source refactors.
- The audit still reports high/critical advisories after `pnpm audit --fix=override --prod`, or pnpm proposes an override outside the production advisory paths.
- An in-scope file drifted.

## Maintenance notes

Keep Raycast API and utils compatible and exact. Review lockfiles as code. Full Raycast build and manual extension smoke tests remain required before publication.
