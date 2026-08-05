# Quick Publish Guide (Bun)

## Prerequisites

```bash
# Login to npm registry (first time only)
bun pm login
```

## Publishing Steps

```bash
# 1. Update version in package.json
# Edit: "version": "0.1.0"

# 2. Build and test
bun run build
bun test

# 3. Verify package contents
bun pm pack --dry-run

# 4. Publish
bun publish

# 5. Tag the release
git tag v0.1.0
git push --tags
```

## Useful Commands

```bash
# Test the build locally
bun run build
./bin/lucius.js --help

# Test library exports
bun -e "import('./dist/index.js').then(mod => console.log(Object.keys(mod)))"

# Create a local tarball for testing
bun pm pack

# Install tarball in another project
bun add /path/to/lucius-0.1.0.tgz

# Link for local development
bun link                 # In this directory
bun link lucius         # In test project
```

## After Publishing

Users can install and use your package:

```bash
# Install
bun add lucius

# Use library
# In dotfiles.config.ts
import { defineConfig } from 'lucius'

# Use CLI
bunx lucius init
bunx lucius apply
```

## Package Structure

- **Library**: `dist/index.js` (1.6KB bundled)
- **CLI**: `bin/lucius.js` (1.1MB bundled)
- **Types**: `dist/**/*.d.ts` (TypeScript declarations)
- **Total**: 64 files, ~1.2MB unpacked

## Quick Debug

```bash
# If build fails
bun run clean && bun run build

# If types are wrong
bun run build:types

# If CLI doesn't work
bun run build:cli
```
