# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Bunsen** is a NixOS flake-inspired dotfiles manager built with TypeScript. It uses `dotfiles.config.ts` as the main configuration file and provides declarative management of:
- Symlinks (GNU stow-like functionality)
- Karabiner keyboard configurations
- Espanso text expansion configs
- Environment variables with shell integration

## Development Commands

```bash
# Install dependencies
bun install

# Run CLI directly from TypeScript source
bun run bunsen -- <command>
bun start -- <command>
./bunsen <command>

# Type checking
bun run typecheck

# Format code
bun run format

# Run tests
bun test

# Run tests with coverage
bun test --coverage
```

**Note:** All commands run directly from TypeScript source - no build step needed!

## Architecture

### TypeScript Execution Strategy

The project runs TypeScript files directly using Bun's native TypeScript support:

**Bun Native TypeScript:**
- Bun natively executes `.ts` files without any compilation or transpilation step
- No build step required at any stage
- No external tools needed (no tsx, no ts-node)
- TypeScript types are stripped at runtime automatically
- Instant startup with no compilation overhead

**Implementation:**
- The `./bunsen` wrapper script directly calls `bun src/cli/index.ts`
- All TypeScript features are supported natively
- No special flags or configuration needed

### Configuration Loading Strategy

User configuration files (`dotfiles.config.ts`) are loaded at runtime:

**Implementation approach in `src/core/config/loader.ts`:**
- Use dynamic `import()` to load user's config file
- Works seamlessly with both .ts and .js config files
- Validate loaded config against Zod schemas
- Expand shell variables (`~`, `$HOME`, etc.) after loading

### Module Dependency Flow

```
CLI Commands (src/cli/commands/)
    ↓
Config Loader (src/core/config/loader.ts)
    ↓
Zod Validation (src/core/config/schema.ts)
    ↓
┌─────────────────┬──────────────────┬──────────────────┐
│                 │                  │                  │
Symlink Manager   Generator: Env     Generator: Karabiner  Generator: Espanso
    ↓                 ↓                   ↓                    ↓
Path Resolver     Shell Integration  karabiner.ts lib      YAML serialization
    ↓
State Tracker (src/core/state/)
```

### State Management

State is persisted at `~/.config/bunsen/state.json` and tracks:
- All symlinks created by Bunsen (source, target, checksum, timestamp)
- Environment file location and injected shell configs
- Used by `status` command and for safe cleanup/rollback

**Critical**: Always update state when creating/removing symlinks to enable idempotent operations.

### Path Resolution

All paths go through `src/core/symlink/resolver.ts`:
1. Expand `~` to `process.env.HOME`
2. Expand environment variables (`$HOME`, `$USER`, etc.)
3. Resolve to absolute paths
4. Validate no `..` traversal attacks

### Conflict Resolution Pattern

When symlink target already exists:
1. Detect type (file, directory, symlink, broken symlink)
2. If interactive mode: prompt user (backup/overwrite/skip)
3. If `--force` flag or `force: true` in config: auto-overwrite
4. Default: backup with `.backup.{timestamp}` suffix

Implemented in `src/core/symlink/conflict.ts`.

### Generator Pattern

All generators (`src/core/generators/`) follow the same pattern:
1. Accept typed config input
2. Transform to target format (JSON, YAML, shell script)
3. Validate output structure
4. Write to configured output path
5. Handle existing files appropriately

### Environment Variable PATH Handling

User controls PATH order by placing `$PATH` token in array:
```typescript
PATH: ['$HOME/.local/bin', '$PATH', '$HOME/.cargo/bin']
// Generates: export PATH="$HOME/.local/bin:$PATH:$HOME/.cargo/bin"
```

### Shell Integration Safety

When injecting into shell configs (`.zshrc`, `.bashrc`):
- Use markers: `# BEGIN LUCIUS` / `# END LUCIUS`
- Idempotent: check for markers before injection
- Always backup before modification
- Source generated env file from within markers

## Key Type Definitions

Core types are in `src/core/config/types.ts`:
- `DotfilesConfig`: Root configuration interface
- `SymlinkConfig`: Symlink declarations (string or object with options)
- `EnvConfig`: Environment variable config with shell targets
- `KarabinerConfig`, `EspansoConfig`: Generator-specific configs

Validation schemas mirror types in `src/core/config/schema.ts` using Zod.

## Testing Strategy

- **Unit tests** (`tests/unit/`): Test individual modules in isolation, mock file system
- **Integration tests** (`tests/integration/`): Test full workflows with real file system in temp directories
- Use Bun's native test runner (`bun:test`) with `mock()` for mocking
- Test fixtures in `tests/fixtures/`

## CLI Structure

Built with Commander.js in `src/cli/index.ts`:
- Global options: `--verbose`, `--dry-run`, `--force`
- Commands implemented in `src/cli/commands/*.ts`
- Each command imports core modules and orchestrates operations
- Use `src/utils/logger.ts` for consistent colored output (chalk)
- Use ora spinners for long-running operations

## API Surface

Public API exported from `src/api/index.ts`:
- `defineConfig(config)`: Type-safe config helper
- `karabiner(config)`: Karabiner configuration builder
- `espanso(config)`: Espanso configuration builder

These are imported by users in their `dotfiles.config.ts` files.

## Critical Implementation Notes

1. **Idempotency**: All operations must be safe to run multiple times. Check state before creating symlinks.

2. **Error Messages**: Use Zod's error formatting for validation errors. Include file paths and actionable suggestions.

3. **Security**: Validate all paths to prevent directory traversal. Don't follow symlinks during validation.

4. **Bun Version**: Minimum v1.0.0 required. Bun natively supports TypeScript without any configuration.

5. **ESM Only**: Project uses ESM exclusively. All imports use `.js` extensions (TypeScript convention).

6. **Dry Run**: The `--dry-run` flag must be threaded through all mutating operations. Log what would happen without executing.

## File Priority for Understanding

To understand the codebase quickly, read in this order:
1. `src/core/config/types.ts` - Core data structures
2. `src/core/config/loader.ts` - How configs are loaded
3. `src/core/symlink/manager.ts` - Core symlink logic
4. `src/cli/commands/apply.ts` - Main orchestration
5. `src/core/state/storage.ts` - State persistence

## Configuration File Location Discovery

CLI should search for `dotfiles.config.ts` in:
1. Current working directory
2. `~/.config/bunsen/dotfiles.config.ts`
3. `~/dotfiles/dotfiles.config.ts`
4. `~/.dotfiles/dotfiles.config.ts`
5. Path specified via `--config` flag

## Dependencies Notes

- **Bun**: JavaScript/TypeScript runtime with native TypeScript support. No transpilation or compilation needed.
- **karabiner.ts**: External library for Karabiner config generation. Wrapper in `src/api/karabiner.ts` provides simplified API.
- **File System**: Uses native Node.js `node:fs` and `node:fs/promises` modules (no external packages needed).
- **Terminal Colors**: Uses native ANSI escape codes via `src/utils/colors.ts` (no external packages needed).
- **Process Execution**: Uses Bun's native `Bun.spawn()` API (no external packages needed).

## Direct TypeScript Execution

Bun's native TypeScript support means no build step is ever needed:

1. **CLI Commands**: `bun run bunsen -- <args>` or `./bunsen <args>`
2. **Direct Execution**: All `.ts` files run directly without compilation
3. **Development Workflow**: Edit TypeScript files → Run immediately → Instant execution

Bun's native TypeScript support eliminates all build complexity and provides instant startup.

## Active Technologies
- TypeScript 5.9.3 with Bun >=1.0.0 + Commander.js (CLI), Zod (validation), existing Bunsen core modules (config loader, state tracker) (001-diff-command)
- File-based (reads ~/.config/bunsen/state.json, reads dotfiles.config.ts) (001-diff-command)

## Recent Changes
- 001-diff-command: Added TypeScript 5.9.3 with Bun >=1.0.0 + Commander.js (CLI), Zod (validation), existing Bunsen core modules (config loader, state tracker)
