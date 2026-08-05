# Development Guide

## Native TypeScript Execution with Bun

Lucius runs TypeScript files directly using Bun's native TypeScript support - no compilation or transpilation needed.

### Quick Start

```bash
# Install dependencies
bun install

# Run any command directly from TypeScript source
bun run lucius -- --help
bun run lucius -- init
bun run lucius -- validate
bun run lucius -- apply --dry-run

# Or use shortcuts
bun start -- --help
./lucius --help
```

### How It Works

The project uses **Bun** to run `.ts` files natively:

1. **bun scripts** (`bun run lucius`) - Directly executes `src/cli/index.ts` with native TS support
2. **Wrapper script** (`./lucius`) - Bash wrapper that calls Bun
3. **No build needed** - Bun handles TypeScript natively without any transpilation

### Development Workflow

```bash
# 1. Make changes to TypeScript files in src/
vim src/cli/commands/apply.ts

# 2. Run immediately - instant execution!
bun run lucius -- apply --dry-run

# 3. Test all commands
bun run lucius -- init
bun run lucius -- validate
bun run lucius -- status

# No build step ever needed - Bun runs TypeScript natively
```

### Available Scripts

```bash
# Run CLI from TypeScript source
bun run lucius -- <args>   # Run CLI from TS source
bun start -- <args>         # Same as above
./lucius <args>             # Wrapper script

# Testing & Quality
bun test                    # Run tests with bun:test
bun test --coverage         # Run tests with coverage
bun run typecheck           # Type check without emit
bun run format              # Format code
```

### Testing Local Changes

When working on Lucius itself, you can import directly from the TypeScript source:

```bash
# In the lucius repo
bun run lucius -- init

# Creates dotfiles.config.ts that imports from source:
# import { defineConfig } from './src/api/index.ts'
```

When Lucius is installed as a package, users import it normally:
```typescript
import { defineConfig } from 'lucius'
```

Bun resolves the package.json `exports` field which points to `./src/api/index.ts`.

### Directory Structure

```
lucius/
├── src/              # TypeScript source (executed directly by Bun)
│   ├── cli/         # CLI commands
│   ├── core/        # Core logic
│   ├── api/         # Public API (exported for users)
│   └── utils/       # Utilities
├── templates/        # Config templates for init command
├── lucius           # Bash wrapper script
└── package.json     # Scripts and dependencies (points to .ts files)
```

**Note:** No `dist/` or `bin/` directories needed - Bun executes TypeScript directly!

### Dependencies for Development

- **Bun**: Runtime with native TypeScript support
- **typescript**: Type checking and IDE support (types only)

### Tips

1. **No build needed**: Develop entirely in TypeScript - Bun runs it natively
2. **Instant execution**: Edit → Run → Test cycle with zero overhead
3. **Type safety**: Full TypeScript checking with `bun run typecheck`
4. **Native performance**: Bun is significantly faster than Node.js

### Common Issues

**Problem**: "Cannot find module" error
**Solution**: Make sure you ran `bun install`

**Problem**: Command not found
**Solution**: Make sure Bun is installed (`curl -fsSL https://bun.sh/install | bash`)

### Performance

- **Bun startup**: ~10-50ms (instant execution)
- **Native TypeScript**: Zero compilation overhead
- **Fast package installs**: Bun is significantly faster than npm

Bun provides production-level performance in development with no build step required.
