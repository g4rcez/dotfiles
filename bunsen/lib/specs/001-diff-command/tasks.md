# Tasks: Diff Command

**Input**: Design documents from `/specs/001-diff-command/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are NOT included (not explicitly requested in feature specification).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- Paths follow Bunsen architecture: CLI → Config → Validation → Managers → State

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create core diff infrastructure shared by all user stories

- [x] T001 Create diff module directory structure (src/core/diff/)
- [x] T002 [P] Create diff types file with type definitions and Zod schemas in src/core/diff/types.ts
- [x] T003 [P] Create diff calculator module stub in src/core/diff/calculator.ts
- [x] T004 [P] Create diff formatter module stub in src/core/diff/formatter.ts

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core types and utilities that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Define DiffEntry type with discriminated union (add/remove/modify) in src/core/diff/types.ts
- [x] T006 Define DiffResult type with section arrays and hasChanges boolean in src/core/diff/types.ts
- [x] T007 Define DiffOptions type with filter flags and configPath in src/core/diff/types.ts
- [x] T008 Define CurrentState and DesiredState types in src/core/diff/types.ts
- [x] T009 Create DiffEntrySchema Zod schema mirroring DiffEntry type in src/core/diff/types.ts
- [x] T010 Create DiffResultSchema Zod schema mirroring DiffResult type in src/core/diff/types.ts
- [x] T011 Create DiffOptionsSchema Zod schema mirroring DiffOptions type in src/core/diff/types.ts
- [x] T012 Export all types and schemas from src/core/diff/types.ts

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Preview Changes Before Applying (Priority: P1) 🎯 MVP

**Goal**: Implement basic diff command that compares current state to desired config and displays color-coded output (red for removals, green for additions). This is the MVP - a working `bunsen diff` command.

**Independent Test**: Run `bunsen diff` with a modified config, verify output shows changes in red/green, confirm no filesystem modifications occur.

### Implementation for User Story 1

- [x] T013 [P] [US1] Implement loadCurrentState function to read state.json and filesystem in src/core/diff/calculator.ts
- [x] T014 [P] [US1] Implement loadDesiredState function to load and normalize config in src/core/diff/calculator.ts
- [x] T015 [US1] Implement compareSymlinks function to generate symlink DiffEntry array in src/core/diff/calculator.ts
- [x] T016 [US1] Implement compareEnv function to generate env DiffEntry array in src/core/diff/calculator.ts
- [x] T017 [US1] Implement compareKarabiner function to generate karabiner DiffEntry array in src/core/diff/calculator.ts
- [x] T018 [US1] Implement compareEspanso function to generate espanso DiffEntry array in src/core/diff/calculator.ts
- [x] T019 [US1] Implement comparePackages function to generate packages DiffEntry array in src/core/diff/calculator.ts
- [x] T020 [US1] Implement calculateDiff function that orchestrates all comparisons and returns DiffResult in src/core/diff/calculator.ts
- [x] T021 [P] [US1] Implement formatDiffEntry function to format single entry with ANSI colors in src/core/diff/formatter.ts
- [x] T022 [P] [US1] Implement formatSection function to format section header and entries in src/core/diff/formatter.ts
- [x] T023 [US1] Implement formatDiffResult function to format complete diff output in src/core/diff/formatter.ts
- [x] T024 [US1] Create diff CLI command handler in src/cli/commands/diff.ts
- [x] T025 [US1] Implement option parsing for --config flag in src/cli/commands/diff.ts
- [x] T026 [US1] Integrate config loader to load user config in src/cli/commands/diff.ts
- [x] T027 [US1] Integrate diff calculator and formatter in src/cli/commands/diff.ts
- [x] T028 [US1] Implement error handling for missing config file in src/cli/commands/diff.ts
- [x] T029 [US1] Implement error handling for invalid config file in src/cli/commands/diff.ts
- [x] T030 [US1] Implement warning for corrupted/missing state file in src/cli/commands/diff.ts
- [x] T031 [US1] Handle "No changes detected" case with appropriate message in src/cli/commands/diff.ts
- [x] T032 [US1] Register diff command with Commander.js in src/cli/index.ts

**Checkpoint**: At this point, `bunsen diff` shows all changes with color-coded output. User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Diff Specific Configuration Sections (Priority: P2)

**Goal**: Add filter flags (--symlinks-only, --env-only, etc.) to show only specific sections of the diff, mirroring `bunsen apply` behavior.

**Independent Test**: Run `bunsen diff --symlinks-only` with changes in multiple sections, verify only symlink changes shown.

### Implementation for User Story 2

- [x] T033 [P] [US2] Add --symlinks-only flag option to diff command in src/cli/commands/diff.ts
- [x] T034 [P] [US2] Add --env-only flag option to diff command in src/cli/commands/diff.ts
- [x] T035 [P] [US2] Add --karabiner-only flag option to diff command in src/cli/commands/diff.ts
- [x] T036 [P] [US2] Add --espanso-only flag option to diff command in src/cli/commands/diff.ts
- [x] T037 [P] [US2] Add --packages-only flag option to diff command in src/cli/commands/diff.ts
- [x] T038 [US2] Implement validateFilterFlags function to ensure mutual exclusion in src/cli/commands/diff.ts
- [x] T039 [US2] Modify calculateDiff to accept DiffOptions and skip sections based on filters in src/core/diff/calculator.ts
- [x] T040 [US2] Update formatDiffResult to only output filtered sections in src/core/diff/formatter.ts
- [x] T041 [US2] Add error message for multiple filter flags used together in src/cli/commands/diff.ts

**Checkpoint**: At this point, User Stories 1 AND 2 both work. Users can preview all changes or filter to specific sections.

---

## Phase 5: User Story 3 - Compare Specific Config File (Priority: P3)

**Goal**: Support --config flag to diff against alternate configuration files, useful for testing new configs.

**Independent Test**: Create alternate config file, run `bunsen diff --config alternate.config.ts`, verify diff reflects alternate config.

### Implementation for User Story 3

- [x] T042 [US3] Update option parsing to handle --config flag value in src/cli/commands/diff.ts
- [x] T043 [US3] Pass configPath from options to config loader in src/cli/commands/diff.ts
- [x] T044 [US3] Add validation that --config path exists and is readable in src/cli/commands/diff.ts
- [x] T045 [US3] Implement error message for invalid --config path with file path in error in src/cli/commands/diff.ts

**Checkpoint**: All user stories (1, 2, 3) are now independently functional. Full feature complete.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements that affect multiple user stories or overall quality

- [x] T046 [P] Add performance optimization for large configs (lazy evaluation) in src/core/diff/calculator.ts
- [x] T047 [P] Add terminal width detection for proper output wrapping in src/core/diff/formatter.ts
- [x] T048 [P] Verify all error messages include file paths and actionable remediation across src/cli/commands/diff.ts
- [x] T049 [P] Ensure all imports use .js extension per ESM requirement across src/core/diff/*.ts
- [x] T050 Run type checking to verify strict type safety (bun run typecheck)
- [x] T051 Verify no mutations occur during diff (read-only validation)
- [x] T052 Test diff command with 100+ symlink config to verify <2s performance goal
- [x] T053 Update CLAUDE.md if needed with diff-specific patterns (likely not needed)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User Story 1 (P1): No dependencies on other stories (MVP)
  - User Story 2 (P2): Extends User Story 1 (adds filters)
  - User Story 3 (P3): Works alongside User Story 1 (adds --config flag)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories ✅ MVP
- **User Story 2 (P2)**: Extends US1, but can be implemented independently after foundation
- **User Story 3 (P3)**: Independent of US1/US2, but builds on same diff command

### Within Each User Story

- **Foundation tasks (T005-T012)**: Must complete before any user story
- **User Story 1**:
  - T013-T014 can run in parallel (load current/desired state)
  - T015-T019 can run in parallel (compare functions)
  - T021-T022 can run in parallel (formatter functions)
  - CLI integration (T024-T032) depends on calculator and formatter
- **User Story 2**:
  - T033-T037 can run in parallel (add flag options)
  - T038-T041 sequential (validation and integration)
- **User Story 3**:
  - T042-T045 sequential (config path handling)

### Parallel Opportunities

- **Setup tasks (T001-T004)**: All can run in parallel
- **Foundation type definitions (T005-T008)**: Sequential (types build on each other)
- **Foundation schemas (T009-T011)**: Can run in parallel once types done
- **US1 compare functions (T015-T019)**: All can run in parallel
- **US1 format functions (T021-T022)**: Can run in parallel
- **US2 flag options (T033-T037)**: All can run in parallel
- **Polish tasks (T046-T049, T053)**: Most can run in parallel

---

## Parallel Example: User Story 1

```bash
# After Foundation complete, launch these in parallel:
Task: "Implement loadCurrentState in src/core/diff/calculator.ts"
Task: "Implement loadDesiredState in src/core/diff/calculator.ts"

# Then launch all compare functions in parallel:
Task: "Implement compareSymlinks in src/core/diff/calculator.ts"
Task: "Implement compareEnv in src/core/diff/calculator.ts"
Task: "Implement compareKarabiner in src/core/diff/calculator.ts"
Task: "Implement compareEspanso in src/core/diff/calculator.ts"
Task: "Implement comparePackages in src/core/diff/calculator.ts"

# And format functions in parallel:
Task: "Implement formatDiffEntry in src/core/diff/formatter.ts"
Task: "Implement formatSection in src/core/diff/formatter.ts"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T012) - CRITICAL
3. Complete Phase 3: User Story 1 (T013-T032)
4. **STOP and VALIDATE**: Test `bunsen diff` independently
5. Verify color output, no mutations, error handling
6. Deploy/demo if ready (MVP complete!)

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (T001-T012)
2. Add User Story 1 → Test independently → Deploy/Demo (T013-T032) ✅ MVP!
3. Add User Story 2 → Test filter flags → Deploy/Demo (T033-T041)
4. Add User Story 3 → Test custom config → Deploy/Demo (T042-T045)
5. Polish phase → Final quality improvements (T046-T053)

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T001-T012)
2. Once Foundational is done:
   - Developer A: User Story 1 core logic (T013-T020)
   - Developer B: User Story 1 formatting (T021-T023)
   - Developer C: User Story 1 CLI integration (T024-T032)
3. After US1 complete:
   - Developer A: User Story 2 (T033-T041)
   - Developer B: User Story 3 (T042-T045)
   - Developer C: Polish (T046-T053)

---

## Notes

- All tasks follow checklist format: `- [ ] [ID] [P?] [Story?] Description with file path`
- [P] tasks = different files, no dependencies, can run in parallel
- [Story] label (US1, US2, US3) maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Constitution compliance: strict types, no build steps, read-only ops, explicit errors, ESM imports
- No test tasks included (not requested in spec per constitution testing requirements)

---

## Task Summary

**Total Tasks**: 53
- Setup: 4 tasks
- Foundational: 8 tasks (CRITICAL BLOCKER)
- User Story 1 (P1 - MVP): 20 tasks
- User Story 2 (P2): 9 tasks
- User Story 3 (P3): 4 tasks
- Polish: 8 tasks

**Parallel Opportunities**: 19 tasks marked [P] for parallel execution

**MVP Scope**: Phases 1-3 (T001-T032) = 32 tasks for working `bunsen diff` command

**Critical Path**: Setup → Foundation (T001-T012) → US1 Core (T013-T020) → US1 Integration (T024-T032)
