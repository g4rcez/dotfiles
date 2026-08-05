# Quickstart: bunsen diff

**Feature**: Preview changes before applying dotfiles configuration
**Estimated Setup Time**: 0 minutes (uses existing configuration)

## Prerequisites

- Bunsen installed (`bun install -g @g4rcez/bunsen` or local install)
- Existing `dotfiles.config.ts` file (create with `bunsen init` if needed)
- Terminal with ANSI color support

## Basic Usage

### 1. Preview All Changes

Show all pending changes between current state and configuration:

```bash
bunsen diff
```

**Example Output**:
```
Symlinks:
+ ~/.zshrc → ~/dotfiles/zsh/.zshrc
  ~/.config/nvim → ~/dotfiles/nvim (unchanged)

Environment Variables:
  EDITOR: vim → nvim
+ PATH: $HOME/.local/bin added

No changes in Karabiner configuration
No changes in Espanso configuration
No changes in packages

Summary: 3 changes detected
```

### 2. Preview Specific Section

Show only symlink changes:

```bash
bunsen diff --symlinks-only
```

Show only environment variable changes:

```bash
bunsen diff --env-only
```

Available filters:
- `--symlinks-only`: Symlink changes only
- `--env-only`: Environment variable changes only
- `--karabiner-only`: Karabiner config changes only
- `--espanso-only`: Espanso config changes only
- `--packages-only`: Package changes only

### 3. Preview with Custom Config

Use a different configuration file:

```bash
bunsen diff --config ~/experiments/test.config.ts
```

## Common Scenarios

### Scenario 1: Before First Apply

**Situation**: You've created a config but never run `bunsen apply`

```bash
bunsen diff
```

**Expected**: All config items shown as additions (green `+`)

```
Warning: No state file found. Showing all items as additions.

Symlinks:
+ ~/.zshrc → ~/dotfiles/zsh/.zshrc
+ ~/.config/nvim → ~/dotfiles/nvim
+ ~/.tmux.conf → ~/dotfiles/tmux/.tmux.conf

Run 'bunsen apply' to create these symlinks.
```

### Scenario 2: After Modifying Config

**Situation**: You added a new symlink to your config

```bash
# Edit dotfiles.config.ts to add ~/.gitconfig
bunsen diff
```

**Expected**: New symlink shown as addition

```
Symlinks:
+ ~/.gitconfig → ~/dotfiles/git/.gitconfig
  ~/.zshrc → ~/dotfiles/zsh/.zshrc (unchanged)

Summary: 1 change detected
```

### Scenario 3: Checking Env Changes

**Situation**: You modified environment variables in config

```bash
bunsen diff --env-only
```

**Expected**: Only env changes shown

```
Environment Variables:
  EDITOR: vim → nvim
+ VISUAL: nvim
- OLD_VAR removed

Summary: 3 env changes detected
```

### Scenario 4: No Changes

**Situation**: Config matches current state

```bash
bunsen diff
```

**Expected**: Confirmation message

```
No changes detected. Current state matches configuration.
```

## Integration with Workflow

### Safe Configuration Changes

Recommended workflow when modifying dotfiles:

```bash
# 1. Edit your config
vim ~/dotfiles/dotfiles.config.ts

# 2. Preview changes
bunsen diff

# 3. If changes look good, apply
bunsen apply

# 4. Verify applied correctly
bunsen status
```

### Testing New Configurations

Test a new config before committing:

```bash
# Create test config
cp dotfiles.config.ts test.config.ts
vim test.config.ts  # Make experimental changes

# Preview test config changes
bunsen diff --config test.config.ts

# If safe, apply
bunsen apply --config test.config.ts
```

### Debugging Unexpected State

If `bunsen status` shows unexpected results:

```bash
# Check what diff thinks should change
bunsen diff

# Compare to actual status
bunsen status

# Investigate discrepancies
```

## Understanding Output

### Color Coding

- **Green `+`**: Addition (new symlink, new variable, new package)
- **Red `-`**: Removal (symlink deleted, variable removed, package uninstalled)
- **Yellow**: Modification (existing value changed)
- **White/Gray**: Unchanged (shown for context)

### Change Types

#### Symlink Changes
```
+ ~/.newfile → ~/dotfiles/new       # Will create symlink
- ~/.oldfile → ~/dotfiles/old       # Will remove symlink
  ~/.file: ~/old → ~/new            # Will update symlink target
```

#### Environment Variable Changes
```
+ VAR: value                        # Will add new variable
- VAR removed                       # Will remove variable
  VAR: old → new                    # Will update variable value
```

#### Generated Config Changes
```
  Karabiner configuration will be regenerated
+ New rule: Caps Lock to Escape
- Removed rule: Old Mapping
```

## Troubleshooting

### "Configuration file not found"

**Problem**: Bunsen can't locate your config

**Solution**:
```bash
# Check where Bunsen is looking
bunsen diff  # Shows searched paths in error

# Specify explicit path
bunsen diff --config ~/path/to/dotfiles.config.ts

# Or create config
bunsen init
```

### "State file corrupted"

**Problem**: `~/.config/bunsen/state.json` is invalid

**Solution**:
```bash
# Diff will show warning but still work
bunsen diff  # All items shown as additions

# Rebuild state by applying
bunsen apply  # Recreates clean state
```

### "Cannot use multiple filter flags"

**Problem**: Used incompatible flags together

**Solution**:
```bash
# Wrong:
bunsen diff --symlinks-only --env-only  # Error!

# Right:
bunsen diff --symlinks-only             # OK
bunsen diff --env-only                  # OK
bunsen diff                             # OK (shows all)
```

### No color output

**Problem**: Terminal doesn't support ANSI colors

**Solution**: Diff command automatically uses colors when supported. If colors don't appear:
- Check terminal supports ANSI (most modern terminals do)
- Verify `TERM` environment variable is set
- Try a different terminal emulator

## Next Steps

- **Apply changes**: `bunsen apply` to execute pending changes
- **Check status**: `bunsen status` to verify current state
- **Learn more**: See full documentation in README.md

## Tips

1. **Always diff before apply**: Prevent accidental overwrites
2. **Use filters for large configs**: Focus on what you changed
3. **Test risky changes**: Use `--config` flag with test file
4. **Check exit code**: Use in scripts to detect changes

```bash
# Script usage
if bunsen diff > /dev/null 2>&1; then
    echo "No changes detected"
else
    echo "Changes pending, review with: bunsen diff"
fi
```
