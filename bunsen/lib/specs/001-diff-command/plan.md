# Implementation Plan: Diff Command

**Branch**: `001-diff-command` | **Date**: 2025-12-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-diff-command/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement a read-only `bunsen diff` command that compares the current filesystem state (from state.json) against the desired state (from dotfiles.config.ts) and displays a color-coded diff preview. This allows users to preview changes before running `bunsen apply`, reducing risk when modifying dotfiles configurations.

**Technical Approach**: Reuse existing config loader and state tracking infrastructure. Create a diff calculator that compares current vs desired state, then format output with ANSI color codes (green for additions, red for removals). Follow existing CLI pattern with Commander.js and support the same filter flags as `apply` command (--symlinks-only, --env-only, etc.).

## Technical Context

**Language/Version**: TypeScript 5.9.3 with Bun >=1.0.0
**Primary Dependencies**: Commander.js (CLI), Zod (validation), existing Bunsen core modules (config loader, state tracker)
**Storage**: File-based (reads ~/.config/bunsen/state.json, reads dotfiles.config.ts)
**Testing**: Bun native test runner
**Target Platform**: macOS and Linux (CLI tool)
**Project Type**: Single project (CLI tool)
**Performance Goals**: Complete diff in <2 seconds for configs with 100+ symlinks
**Constraints**: Read-only operation (MUST NOT modify filesystem or state), must handle missing/corrupted state gracefully
**Scale/Scope**: Handle configs with hundreds of symlinks, multiple env vars, multiple generated configs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify compliance with Bunsen Constitution (`.specify/memory/constitution.md`):

- [x] **Strict Type Safety**: All inputs/outputs explicitly typed, no implicit `any`, Zod schemas mirror types
  - **Status**: ✅ PASS - DiffEntry, DiffResult, DiffOptions all have corresponding Zod schemas defined in data-model.md
- [x] **Runtime Without Build Steps**: Direct TypeScript execution via Bun, no transpilation, dynamic imports for config
  - **Status**: ✅ PASS - Reuses existing config loader with dynamic imports, no build step required
- [x] **Idempotent Operations**: All mutations safe to repeat, state tracking implemented
  - **Status**: ✅ PASS - Diff command is read-only, performs zero mutations to filesystem or state
- [x] **Security First**: Path validation prevents traversal, environment expansion post-validation, no symlink following
  - **Status**: ✅ PASS - Reuses existing path resolution/validation from src/core/symlink/resolver.ts
- [x] **Minimal Comments, Maximum Types**: Self-documenting code, comments only for non-obvious logic
  - **Status**: ✅ PASS - Data model uses explicit types, comment-free self-documenting approach
- [x] **Code Structure Follows Dependency Flow**: Modules organized per architecture (CLI → Config → Validation → Managers → State)
  - **Status**: ✅ PASS - New src/core/diff/ module follows existing pattern, CLI→Calculator→Formatter→Output
- [x] **ESM Only**: All imports use `.js` extensions
  - **Status**: ✅ PASS - All new files will follow existing `.js` import convention
- [x] **No External Dependencies for Core**: Native Node.js APIs used (fs, path), Bun APIs for spawning
  - **Status**: ✅ PASS - Uses existing logger (ANSI codes), fs utils, no new dependencies
- [x] **Explicit Error Messages**: Zod error formatting, file paths, actionable remediation included
  - **Status**: ✅ PASS - CLI contract specifies detailed error messages with file paths and remediation
- [x] **Testing Requirements**: Bun test runner, mocked unit tests, temp dir integration tests
  - **Status**: ✅ PASS - Test structure defined: unit tests for calculator/formatter, integration test for CLI

**Overall Constitution Compliance**: ✅ ALL GATES PASSED - No violations, no complexity tracking needed

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
src/
├── cli/
│   ├── commands/
│   │   ├── diff.ts           # NEW: Diff command implementation
│   │   ├── apply.ts           # Existing: Reference for patterns
│   │   ├── status.ts          # Existing: Reference for state reading
│   │   └── ...
│   └── index.ts               # UPDATE: Register new diff command
├── core/
│   ├── diff/
│   │   ├── calculator.ts      # NEW: Core diff calculation logic
│   │   ├── formatter.ts       # NEW: Format diff entries for output
│   │   └── types.ts           # NEW: Diff-specific types
│   ├── config/
│   │   ├── loader.ts          # REUSE: Load user config
│   │   ├── schema.ts          # REUSE: Zod validation
│   │   └── types.ts           # REUSE: Config types
│   ├── state/
│   │   ├── storage.ts         # REUSE: Load state.json
│   │   └── tracker.ts         # REUSE: State reading utilities
│   └── symlink/
│       └── manager.ts         # REFERENCE: Understand symlink operations
└── utils/
    ├── logger.ts              # REUSE: ANSI color utilities
    └── fs.ts                  # REUSE: Filesystem helpers

tests/
├── unit/
│   └── diff/
│       ├── calculator.test.ts # NEW: Test diff calculation
│       └── formatter.test.ts  # NEW: Test output formatting
└── integration/
    └── diff.test.ts           # NEW: End-to-end diff command tests
```

**Structure Decision**: Single project structure following existing Bunsen architecture. New code isolated in `src/core/diff/` module following the "Code Structure Follows Dependency Flow" principle. CLI command at `src/cli/commands/diff.ts` following existing patterns from apply/status commands. Tests mirror source structure per Bunsen conventions.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
