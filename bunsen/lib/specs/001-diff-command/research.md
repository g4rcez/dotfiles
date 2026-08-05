# Research: Diff Command Implementation

**Feature**: bunsen diff
**Date**: 2025-12-16
**Status**: Complete

## Research Areas

### 1. Diff Calculation Strategy

**Decision**: Separate diff calculation per configuration section (symlinks, env, karabiner, espanso, packages)

**Rationale**:
- Each section has different comparison logic (symlinks compare filesystem state, env compares variables, etc.)
- Allows independent filtering via --symlinks-only, --env-only flags
- Mirrors existing `apply` command architecture which processes sections independently
- Enables parallel diff calculation if needed for performance

**Alternatives Considered**:
- **Unified diff calculator**: Rejected because each section has fundamentally different comparison requirements (file-based vs content-based vs list-based)
- **Dry-run apply then capture output**: Rejected because it couples diff to apply logic and risks accidentally triggering side effects

**Implementation Approach**:
- Create `DiffCalculator` class with methods for each section
- Each method returns array of `DiffEntry` objects with changeType (add/remove/modify)
- Symlink diff: Compare state.json symlinks vs config symlinks using target path as key
- Env diff: Parse existing env file vs config env variables
- Generated config diff: Read existing karabiner.json/espanso.yml vs what would be generated
- Package diff: Compare installed packages (via package manager queries) vs config packages

### 2. Output Formatting Strategy

**Decision**: Use ANSI escape codes directly (no external color libraries)

**Rationale**:
- Bunsen constitution mandates no external dependencies for core operations
- Project already has ANSI utilities in `src/utils/logger.ts` for colored output
- Standard ANSI codes (green `\x1b[32m`, red `\x1b[31m`) are universally supported
- Maintains consistency with existing logger output patterns

**Alternatives Considered**:
- **chalk library**: Rejected due to constitution constraint on external dependencies
- **No colors**: Rejected because spec explicitly requires color-coded output for usability

**Implementation Approach**:
- Extend existing logger utility with diff-specific formatting functions
- Format: `- [red text]` for removals, `+ [green text]` for additions
- Group diff entries by section with headers
- Handle terminal width detection for proper wrapping (use process.stdout.columns)

### 3. State Comparison Edge Cases

**Decision**: Handle missing/corrupted state gracefully with clear messaging

**Rationale**:
- Users may run `bunsen diff` before first `bunsen apply` (no state file exists)
- State file may be corrupted or version-incompatible
- Filesystem may have changed outside of Bunsen (manual symlink modifications)

**Implementation Approach**:
- If no state file: Show all config items as additions (everything will be created)
- If corrupted state: Warn user, show diff with caveat about state accuracy
- If symlink exists but not in state: Mark as "untracked by Bunsen" in diff output
- Use existing state loading error handling from `loadState()` function

### 4. Performance Optimization

**Decision**: Lazy evaluation and early exit for filtered diffs

**Rationale**:
- When user runs `--symlinks-only`, no need to calculate env/karabiner/espanso diffs
- For configs with hundreds of symlinks, avoid unnecessary filesystem reads
- Spec requires <2 second completion for 100 symlinks

**Implementation Approach**:
- Check filter flags before calculating each section's diff
- Use async/await for filesystem reads but avoid excessive parallelism (keep it simple)
- Batch filesystem stat calls when checking symlink existence
- Profile with large configs during testing to identify bottlenecks

### 5. Diff Entry Data Model

**Decision**: Unified DiffEntry type with discriminated union for change types

**Rationale**:
- TypeScript discriminated unions provide type safety for different change types
- Enables exhaustive pattern matching when formatting output
- Single type simplifies passing diff results between calculator and formatter

**Type Structure**:
```typescript
type ChangeType = 'add' | 'remove' | 'modify'
type SectionType = 'symlink' | 'env' | 'karabiner' | 'espanso' | 'packages'

interface DiffEntry {
  section: SectionType
  changeType: ChangeType
  path: string  // Target path or identifier
  oldValue?: string  // For remove/modify
  newValue?: string  // For add/modify
  details?: Record<string, unknown>  // Section-specific metadata
}
```

**Alternatives Considered**:
- **Separate types per section**: Rejected because it complicates aggregation and formatting
- **Generic key-value diff**: Rejected because it loses section-specific semantics

### 6. Integration with Existing Code

**Decision**: Reuse config loader, state tracker, and logger without modification

**Rationale**:
- Existing modules are well-tested and follow constitution principles
- No need to duplicate config loading or state reading logic
- Diff is a read-only operation, so no risk of interfering with apply logic

**Modules to Reuse**:
- `src/core/config/loader.ts`: Load and validate user config
- `src/core/state/storage.ts`: Load state.json with error handling
- `src/core/state/tracker.ts`: Read current symlink statuses
- `src/utils/logger.ts`: Terminal output with colors
- `src/utils/fs.ts`: Filesystem helpers (pathExists, readFile, etc.)

**New Modules to Create**:
- `src/core/diff/calculator.ts`: Diff calculation logic
- `src/core/diff/formatter.ts`: Format diff entries for terminal output
- `src/core/diff/types.ts`: DiffEntry and related types
- `src/cli/commands/diff.ts`: CLI command handler

## Technology Decisions Summary

| Decision Area | Choice | Key Constraint |
|---------------|--------|----------------|
| Diff Strategy | Section-based calculation | Constitution: Code Structure Follows Dependency Flow |
| Output Colors | Native ANSI codes | Constitution: No External Dependencies for Core |
| State Handling | Graceful degradation | Spec: Handle missing/corrupted state |
| Performance | Lazy evaluation + filtering | Spec: <2s for 100 symlinks |
| Type Model | Discriminated union DiffEntry | Constitution: Strict Type Safety |
| Code Reuse | Leverage existing modules | Constitution: Idempotent Operations (read-only) |

## Open Questions (Resolved)

None. All technical decisions have clear answers based on existing codebase patterns and constitution constraints.
