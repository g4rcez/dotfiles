# Data Model: Diff Command

**Feature**: bunsen diff
**Date**: 2025-12-16

## Core Entities

### DiffEntry

Represents a single change detected between current state and desired configuration.

**Fields**:
- `section`: Type of configuration section (symlink | env | karabiner | espanso | packages)
- `changeType`: Nature of the change (add | remove | modify)
- `path`: Target path or identifier for the change
- `oldValue`: Previous value (for remove/modify operations), undefined for additions
- `newValue`: New value (for add/modify operations), undefined for removals
- `details`: Optional section-specific metadata

**Validation Rules**:
- `section` must be one of the five valid section types
- `changeType` must be one of the three valid change types
- `path` must be non-empty string
- For `add` changeType: `newValue` required, `oldValue` must be undefined
- For `remove` changeType: `oldValue` required, `newValue` must be undefined
- For `modify` changeType: both `oldValue` and `newValue` required

**State Transitions**: N/A (immutable value object)

**Relationships**:
- Multiple DiffEntry objects are aggregated into a DiffResult
- Each DiffEntry corresponds to exactly one section of the configuration

### DiffResult

Collection of all diff entries grouped by section, representing the complete comparison result.

**Fields**:
- `symlinks`: Array of DiffEntry objects for symlink changes
- `env`: Array of DiffEntry objects for environment variable changes
- `karabiner`: Array of DiffEntry objects for Karabiner config changes
- `espanso`: Array of DiffEntry objects for Espanso config changes
- `packages`: Array of DiffEntry objects for package installation changes
- `hasChanges`: Boolean indicating if any changes exist across all sections

**Validation Rules**:
- Each array contains only DiffEntry objects matching the corresponding section type
- `hasChanges` must be true if any array has length > 0, false otherwise

**State Transitions**: N/A (immutable value object)

**Relationships**:
- Contains multiple DiffEntry objects
- Consumed by DiffFormatter to generate terminal output

### DiffOptions

Configuration for how the diff should be calculated and displayed.

**Fields**:
- `configPath`: Optional custom path to dotfiles config file
- `symlinksOnly`: Boolean filter to show only symlink changes
- `envOnly`: Boolean filter to show only environment variable changes
- `karabinerOnly`: Boolean filter to show only Karabiner config changes
- `espansoOnly`: Boolean filter to show only Espanso config changes
- `packagesOnly`: Boolean filter to show only package changes

**Validation Rules**:
- At most one filter flag can be true (mutually exclusive filters)
- If `configPath` provided, must be valid file path

**State Transitions**: N/A (immutable value object)

**Relationships**:
- Passed to DiffCalculator to control which sections are compared
- Derived from CLI command flags

### CurrentState

Snapshot of the actual filesystem state and tracked Bunsen operations.

**Fields**:
- `symlinks`: Array of symlink entries from state.json
- `envFile`: Path to generated env file, if exists
- `envVariables`: Parsed environment variables from existing env file
- `karabinerConfig`: Parsed Karabiner configuration, if exists
- `espansoConfig`: Parsed Espanso configuration, if exists
- `installedPackages`: Map of package manager to installed package list

**Validation Rules**:
- `symlinks` array validated against StateFileSchema
- Config files parsed and validated if they exist, null otherwise
- Installed packages queried from actual package managers

**State Transitions**: N/A (read-only snapshot)

**Relationships**:
- Loaded from `~/.config/bunsen/state.json` and filesystem
- Compared against DesiredState to produce DiffEntry objects

### DesiredState

Configuration state derived from parsing dotfiles.config.ts.

**Fields**:
- `symlinks`: Normalized symlink configuration from config
- `envVariables`: Environment variables from config.env
- `karabinerConfig`: Karabiner configuration from config.karabiner
- `espansoConfig`: Espanso configuration from config.espanso
- `packages`: Package lists from config.packages

**Validation Rules**:
- All fields validated against existing DotfilesConfig Zod schema
- Paths resolved and normalized before comparison

**State Transitions**: N/A (immutable value object)

**Relationships**:
- Loaded via config loader and normalized
- Compared against CurrentState to produce DiffEntry objects

## Type Hierarchies

```
DiffEntry (discriminated by changeType)
├── Addition: { changeType: 'add', newValue: string, oldValue: undefined }
├── Removal: { changeType: 'remove', oldValue: string, newValue: undefined }
└── Modification: { changeType: 'modify', oldValue: string, newValue: string }

SectionType (string union)
├── 'symlink'
├── 'env'
├── 'karabiner'
├── 'espanso'
└── 'packages'
```

## Data Flow

```
1. Load CurrentState from filesystem + state.json
   ↓
2. Load DesiredState from dotfiles.config.ts
   ↓
3. DiffCalculator.compare(CurrentState, DesiredState, DiffOptions)
   ↓
4. Generate DiffEntry[] for each section
   ↓
5. Aggregate into DiffResult
   ↓
6. DiffFormatter.format(DiffResult)
   ↓
7. ANSI-colored terminal output
```

## Example Diff Entries

### Symlink Addition
```typescript
{
  section: 'symlink',
  changeType: 'add',
  path: '~/.zshrc',
  oldValue: undefined,
  newValue: '~/dotfiles/zsh/.zshrc',
  details: { targetExists: false }
}
```

### Environment Variable Modification
```typescript
{
  section: 'env',
  changeType: 'modify',
  path: 'EDITOR',
  oldValue: 'vim',
  newValue: 'nvim',
  details: { shellsAffected: ['zsh', 'bash'] }
}
```

### Package Removal
```typescript
{
  section: 'packages',
  changeType: 'remove',
  path: 'wget',
  oldValue: 'installed via brew',
  newValue: undefined,
  details: { packageManager: 'brew' }
}
```

## Zod Schema Mappings

All entities mirror corresponding Zod schemas:

- `DiffEntry` → `DiffEntrySchema` (new, defined in src/core/diff/types.ts)
- `DiffResult` → `DiffResultSchema` (new, defined in src/core/diff/types.ts)
- `DiffOptions` → `DiffOptionsSchema` (new, defined in src/core/diff/types.ts)
- `CurrentState` → Uses existing `StateFileSchema` + runtime filesystem reads
- `DesiredState` → Uses existing `DotfilesConfigSchema`

Constitution requirement: All TypeScript types have matching Zod schemas for runtime validation.
