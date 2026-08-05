# Feature Specification: Diff Command

**Feature Branch**: `001-diff-command`
**Created**: 2025-12-16
**Status**: Draft
**Input**: User description: "bunsen diff - Show diff between current state and dry run of next apply. Users can preview changes before running bunsen apply. Use red for removed/old state and green for added/new state"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Preview Changes Before Applying (Priority: P1)

A user has modified their `dotfiles.config.ts` file and wants to see exactly what will change when they run `bunsen apply` without actually making those changes. They run `bunsen diff` to get a color-coded preview showing what will be added, removed, or modified.

**Why this priority**: This is the core value proposition of the feature. Users need confidence before applying changes to their dotfiles, especially when modifying symlinks or shell configurations that could break their environment. This is the MVP - a simple diff command that shows what will change.

**Independent Test**: Can be fully tested by creating a dotfiles config, running `bunsen diff`, verifying the output shows pending changes in red/green, and confirming that no actual changes are made to the filesystem or state.

**Acceptance Scenarios**:

1. **Given** a dotfiles configuration with new symlinks not yet created, **When** user runs `bunsen diff`, **Then** output shows the new symlinks to be created in green with "+" prefix
2. **Given** existing symlinks that will be modified, **When** user runs `bunsen diff`, **Then** output shows old target in red with "-" prefix and new target in green with "+" prefix
3. **Given** symlinks that will be removed, **When** user runs `bunsen diff`, **Then** output shows symlinks to be removed in red with "-" prefix
4. **Given** no changes between current state and config, **When** user runs `bunsen diff`, **Then** output shows "No changes detected"

---

### User Story 2 - Diff Specific Configuration Sections (Priority: P2)

A user wants to preview changes for only specific parts of their configuration (e.g., just symlinks or just environment variables) without seeing the full diff. They use filter flags like `bunsen diff --symlinks-only` or `bunsen diff --env-only`.

**Why this priority**: After the basic diff works, users with large configurations benefit from focused diffs. This mirrors the existing `bunsen apply` behavior which supports section-specific flags.

**Independent Test**: Can be tested by running `bunsen diff --symlinks-only` and verifying only symlink changes are shown, even when env or karabiner configs also have pending changes.

**Acceptance Scenarios**:

1. **Given** pending changes in both symlinks and environment variables, **When** user runs `bunsen diff --symlinks-only`, **Then** output shows only symlink changes, ignoring env changes
2. **Given** pending changes in multiple sections, **When** user runs `bunsen diff --env-only`, **Then** output shows only environment variable changes
3. **Given** pending karabiner changes, **When** user runs `bunsen diff --karabiner-only`, **Then** output shows only karabiner configuration changes

---

### User Story 3 - Compare Specific Config File (Priority: P3)

A user wants to preview the diff for a config file other than the default location. They use `bunsen diff --config path/to/config.ts` to specify which configuration to compare.

**Why this priority**: Useful for testing new configurations or managing multiple dotfiles setups, but less critical than core diff functionality.

**Independent Test**: Can be tested by creating an alternate config file, running `bunsen diff --config alternate.config.ts`, and verifying the diff reflects that config instead of the default.

**Acceptance Scenarios**:

1. **Given** an alternate config file path, **When** user runs `bunsen diff --config alternate.config.ts`, **Then** diff compares current state against the alternate config
2. **Given** an invalid config file path, **When** user runs `bunsen diff --config nonexistent.ts`, **Then** system shows error message with file path and exits gracefully

---

### Edge Cases

- What happens when the config file has syntax errors or fails validation?
- How does the system handle broken symlinks or missing source files?
- What happens when there are filesystem permission errors preventing reading current state?
- How does diff handle very large configurations with hundreds of symlinks?
- What happens if the state file is corrupted or missing?
- How does the system display changes when shell injection markers exist but env config changed?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST compare current filesystem state against the configuration file to identify pending changes
- **FR-002**: System MUST display additions in green with "+" prefix and removals in red with "-" prefix
- **FR-003**: System MUST show modifications as paired red/green lines (old value in red, new value in green)
- **FR-004**: System MUST detect and display symlink changes (new, modified target, removed)
- **FR-005**: System MUST detect and display environment variable changes (new variables, modified values, removed variables)
- **FR-006**: System MUST detect and display changes to generated config files (Karabiner, Espanso)
- **FR-007**: System MUST detect and display package installation changes (new packages, removed packages)
- **FR-008**: System MUST support filtering by configuration section (--symlinks-only, --env-only, --karabiner-only, --espanso-only, --packages-only)
- **FR-009**: System MUST support custom config file path via --config flag
- **FR-010**: System MUST display "No changes detected" when current state matches configuration
- **FR-011**: System MUST NOT modify any files or state (read-only operation)
- **FR-012**: System MUST use existing state tracking to determine current state
- **FR-013**: System MUST validate configuration file before generating diff
- **FR-014**: System MUST display clear error messages if config is invalid or missing

### Key Entities

- **Diff Entry**: Represents a single change to be applied, includes change type (addition/removal/modification), section (symlink/env/karabiner/espanso/packages), old value, new value, target path
- **Current State**: The actual filesystem state and tracked operations from state.json
- **Desired State**: The state derived from parsing the dotfiles configuration file
- **Section Filter**: Which configuration sections to include in the diff output

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can preview all pending changes by running a single command without modifying any files
- **SC-002**: Users can distinguish between additions, removals, and modifications through color coding within 3 seconds of viewing output
- **SC-003**: Users can filter diff output to specific configuration sections to focus on relevant changes
- **SC-004**: Diff command completes in under 2 seconds for configurations with up to 100 symlinks
- **SC-005**: System accurately identifies 100% of differences between current state and configuration with zero false positives
- **SC-006**: Error messages provide actionable guidance when configuration is invalid or missing

## Assumptions

- Users have already run `bunsen apply` at least once, establishing initial state tracking
- The existing state tracking mechanism (`~/.config/bunsen/state.json`) accurately reflects what Bunsen has created
- Configuration file validation reuses existing Zod schemas from the apply command
- Color output uses standard ANSI escape codes (same approach as existing logger utility)
- Diff output format mirrors common Unix diff tools (-, +, and context) for familiarity
- Users interact with this command via terminal environments that support ANSI colors
