# Publishing Guide

This document explains how to publish the Lucius package to npm and Bun's package registry.

## Package Structure

Lucius is published as a dual-purpose package:

1. **Library Package** (`dist/index.js`): Provides the API for use in `dotfiles.config.ts`
2. **CLI Package** (`bin/lucius.js`): Executable command-line tool

## Build Process

The build process uses Bun's native bundler and TypeScript's declaration generator:

```bash
# Clean previous builds and build everything
bun run build

# Individual build steps:
bun run clean           # Remove dist/ and bin/*.js
bun run build:lib       # Bundle the library API
bun run build:cli       # Bundle the CLI with shebang
bun run build:types     # Generate TypeScript declarations
```

### What Gets Built

- **Library**: `dist/index.js` - Bundled ESM module with all API exports
- **CLI**: `bin/lucius.js` - Bundled executable with `#!/usr/bin/env node` shebang
- **Types**: `dist/**/*.d.ts` - TypeScript type declarations for the entire codebase
- **Source Maps**: `dist/index.js.map` - Source maps for debugging

## Publishing with Bun

1. **Update version** in `package.json`:
   ```bash
   # Manually edit package.json or use a tool
   # Update the version field: "version": "0.1.0"
   ```

2. **Test the build**:
   ```bash
   bun run build
   bun test
   ```

3. **Verify package contents**:
   ```bash
   bun pm pack --dry-run
   ```

4. **Login to npm registry** (first time only):
   ```bash
   bun pm login
   ```

5. **Publish to npm**:
   ```bash
   bun publish
   ```

   The `prepublishOnly` script will automatically run the build before publishing.

## Publishing to Bun Registry

Packages published to npm are automatically available in Bun's registry.

```bash
# Publish using Bun
bun publish

# Install via Bun
bun add lucius

# Use the CLI
bunx lucius
```

## Package Contents

The published package includes:

- `dist/` - Compiled JavaScript and type declarations
- `bin/` - CLI executable
- `templates/` - Template files for `lucius init`
- `README.md` - Documentation
- `LICENSE` - License file

**Excluded** (via `.npmignore`):
- `src/` - TypeScript source files (use dist/ instead)
- `tests/` - Test files
- `examples/` - Example configurations
- `scripts/` - Build scripts
- Configuration files (.prettierrc, tsconfig.json, etc.)

## Version Checklist

Before publishing:

- [ ] Update version in `package.json`
- [ ] Update CHANGELOG.md with release notes
- [ ] Run `bun run build` successfully
- [ ] Run `bun test` - all tests pass
- [ ] Test CLI: `./bin/lucius.js --help`
- [ ] Test library: `bun -e "import('./dist/index.js').then(console.log)"`
- [ ] Verify package contents: `bun pm pack --dry-run`
- [ ] Create git tag: `git tag v$(bun -e "console.log(require('./package.json').version)")`
- [ ] Push tag: `git push --tags`

## Testing Locally

To test the package locally before publishing:

```bash
# Build the package
bun run build

# Create a tarball
bun pm pack

# In another project, install the tarball
bun add /path/to/lucius-0.0.0.tgz

# Or use bun link
bun link                    # In lucius directory
bun link lucius            # In test project
```

## Library Usage Example

After publishing, users can use the library like this:

```typescript
// dotfiles.config.ts
import { defineConfig, karabiner, espanso } from 'lucius'

export default defineConfig({
  symlinks: {
    '~/.config/nvim': './nvim',
    '~/.zshrc': './zsh/.zshrc',
  },
  karabiner: karabiner({
    profiles: [
      {
        name: 'Default',
        rules: [/* ... */],
      },
    ],
    outputPath: '~/.config/karabiner/karabiner.json',
  }),
})
```

## CLI Usage Example

```bash
# Install globally with Bun
bun add -g lucius

# Or use with bunx (no installation needed)
bunx lucius init
bunx lucius apply
bunx lucius status
```

## Troubleshooting

### Build fails with TypeScript errors

- Check that all imports use correct paths
- Ensure Zod schema types match interface types
- Run `bun run typecheck` to see detailed errors

### CLI doesn't execute

- Verify shebang: `head -n 1 bin/lucius.js`
- Check executable permission: `ls -l bin/lucius.js`
- Rebuild: `bun run build:cli`

### Library exports are missing

- Check `src/api/index.ts` exports
- Verify `dist/index.js` was created: `ls -l dist/`
- Test imports: `bun -e "import('./dist/index.js').then(console.log)"`

## Package Registry URLs

- **npm**: https://www.npmjs.com/package/lucius
- **Bun**: https://bun.sh/packages/lucius
