# CLI Interface Contract: bunsen diff

**Command**: `bunsen diff`
**Type**: Read-only inspection command
**Exit Codes**: 0 (success), 1 (error), 2 (validation failure)

## Command Signature

```bash
bunsen diff [options]
```

## Options

### `--config <path>`
- **Type**: String (file path)
- **Required**: No
- **Default**: Auto-discovered from standard locations
- **Description**: Path to dotfiles configuration file
- **Validation**: File must exist and be readable
- **Example**: `bunsen diff --config ~/dotfiles/alternate.config.ts`

### `--symlinks-only`
- **Type**: Boolean flag
- **Required**: No
- **Default**: false
- **Description**: Show only symlink changes, ignore other sections
- **Mutually Exclusive**: Cannot be used with other filter flags
- **Example**: `bunsen diff --symlinks-only`

### `--env-only`
- **Type**: Boolean flag
- **Required**: No
- **Default**: false
- **Description**: Show only environment variable changes
- **Mutually Exclusive**: Cannot be used with other filter flags
- **Example**: `bunsen diff --env-only`

### `--karabiner-only`
- **Type**: Boolean flag
- **Required**: No
- **Default**: false
- **Description**: Show only Karabiner configuration changes
- **Mutually Exclusive**: Cannot be used with other filter flags
- **Example**: `bunsen diff --karabiner-only`

### `--espanso-only`
- **Type**: Boolean flag
- **Required**: No
- **Default**: false
- **Description**: Show only Espanso configuration changes
- **Mutually Exclusive**: Cannot be used with other filter flags
- **Example**: `bunsen diff --espanso-only`

### `--packages-only`
- **Type**: Boolean flag
- **Required**: No
- **Default**: false
- **Description**: Show only package installation changes
- **Mutually Exclusive**: Cannot be used with other filter flags
- **Example**: `bunsen diff --packages-only`

## Output Format

### Successful Diff with Changes

```
Symlinks:
+ ~/.zshrc → ~/dotfiles/zsh/.zshrc
- ~/.vimrc → ~/dotfiles/vim/.vimrc (will be removed)
  ~/.config/nvim → ~/dotfiles/nvim (unchanged)

Environment Variables:
  EDITOR: vim → nvim
+ PATH: /usr/local/bin added
- NODE_ENV removed

Karabiner:
  Configuration will be regenerated
+ New rule: Caps Lock to Escape

Summary: 5 changes detected
```

**Color Coding**:
- Green `+` prefix: Additions (new symlinks, new variables, etc.)
- Red `-` prefix: Removals (symlinks removed, variables deleted, etc.)
- Yellow/white for context and modifications

### Successful Diff with No Changes

```
No changes detected. Current state matches configuration.
```

**Exit Code**: 0

### Error Cases

#### Config File Not Found
```
Error: Configuration file not found
Searched in:
  - ./dotfiles.config.ts
  - ~/.config/bunsen/dotfiles.config.ts
  - ~/dotfiles/dotfiles.config.ts
  - ~/.dotfiles/dotfiles.config.ts

Run 'bunsen init' to create a configuration file.
```
**Exit Code**: 1

#### Config File Invalid
```
Error: Configuration validation failed
File: /path/to/dotfiles.config.ts

Validation errors:
  - symlinks.~/.zshrc: Expected string or object, received number
  - env.variables.PATH: Expected array, received string

Fix these errors and try again.
```
**Exit Code**: 2

#### State File Corrupted
```
Warning: State file is corrupted or invalid
Using fallback: all config items will appear as additions

Symlinks:
+ ~/.zshrc → ~/dotfiles/zsh/.zshrc (may already exist)
...

Run 'bunsen apply' to rebuild state tracking.
```
**Exit Code**: 0 (warning, not error)

#### Permission Denied
```
Error: Permission denied reading state file
File: ~/.config/bunsen/state.json

Check file permissions and try again.
```
**Exit Code**: 1

## Behavioral Contracts

### Contract 1: Read-Only Operation
**Given**: Any system state
**When**: User runs `bunsen diff`
**Then**:
- No files are created, modified, or deleted
- state.json is not modified
- No symlinks are created or removed
- No shell configs are modified

### Contract 2: Accurate Change Detection
**Given**: Current state with 3 symlinks and desired config with 4 symlinks
**When**: User runs `bunsen diff`
**Then**:
- Shows 1 addition (new symlink)
- Shows 3 unchanged (existing symlinks)
- Diff entries match actual filesystem state vs config

### Contract 3: Filter Flag Isolation
**Given**: Changes in symlinks, env, and karabiner sections
**When**: User runs `bunsen diff --symlinks-only`
**Then**:
- Output shows only symlink changes
- Env and karabiner changes are not displayed
- Exit code reflects overall success, not filtered sections

### Contract 4: Missing State Handling
**Given**: No state.json file exists (fresh system)
**When**: User runs `bunsen diff`
**Then**:
- Shows warning about missing state
- Displays all config items as additions
- Exit code 0 (not an error condition)

### Contract 5: Mutual Exclusion of Filters
**Given**: User attempts to run `bunsen diff --symlinks-only --env-only`
**When**: Command is executed
**Then**:
- Shows error: "Cannot use multiple filter flags together"
- Exit code 1
- No diff calculation performed

## Performance Contracts

### Contract 6: Response Time
**Given**: Configuration with 100 symlinks, 20 env vars, 2 generated configs
**When**: User runs `bunsen diff`
**Then**:
- Command completes in <2 seconds
- Output is streamed immediately (no buffering delay)

### Contract 7: Large Config Handling
**Given**: Configuration with 500+ symlinks
**When**: User runs `bunsen diff`
**Then**:
- Command completes without timeout
- Memory usage stays below 100MB
- Output is properly paginated if terminal supports it

## Integration Points

### Input Sources
1. **Config File**: `dotfiles.config.ts` (via config loader)
2. **State File**: `~/.config/bunsen/state.json` (via state storage)
3. **Filesystem**: Actual symlinks and config files (via fs utilities)

### Output Destinations
1. **stdout**: Normal diff output with ANSI colors
2. **stderr**: Error messages and warnings
3. **Exit Code**: Success/failure indicator for scripting

### Dependencies
- Config Loader: Reuse `src/core/config/loader.ts`
- State Storage: Reuse `src/core/state/storage.ts`
- Logger: Reuse `src/utils/logger.ts` for colored output
- FS Utilities: Reuse `src/utils/fs.ts` for file operations

## Validation Rules

1. **At most one filter flag**: Validate flag combinations before diff calculation
2. **Config path must exist**: Validate file exists if --config provided
3. **No mutations**: Assert no filesystem changes during diff operation
4. **Output format**: Ensure ANSI codes are valid and terminal-compatible
5. **Exit codes**: Map to correct codes based on error type
