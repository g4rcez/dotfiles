---
description: Review and configure Biome setups for TypeScript/JavaScript projects
argument-hint: <file-or-pattern>
---

# Biome Review

Review these files for compliance: $ARGUMENTS

Read `biome.json` and any referenced config files. Output concise but comprehensive—sacrifice grammar for brevity. High signal-to-noise.

## Rules

### biome.json Structure

- Top-level keys: `$schema`, `formatter`, `linter`, `javascript`, `json`, `organizeImports`, `files`, `overrides`
- Always include `"$schema": "https://biomejs.dev/schemas/VERSION/schema.json"` — enables IDE validation
- `vcs.enabled = true` + `vcs.useIgnoreFile = true` to respect `.gitignore`

### Formatter

- `formatter.enabled = true` (default); set `indentStyle`, `indentWidth`, `lineWidth`
- `formatter.formatWithErrors = false` — don't format files with parse errors
- `javascript.formatter.quoteStyle` — `"single"` or `"double"`; be consistent with existing codebase
- `javascript.formatter.semicolons` — `"always"` or `"asNeeded"`
- `javascript.formatter.trailingCommas` — `"all"` (ES2017+) recommended

### Linter

- `linter.enabled = true`
- Enable recommended rules: `"rules": { "recommended": true }`
- Extend with specific rule groups: `correctness`, `suspicious`, `style`, `performance`, `security`, `complexity`, `nursery`
- Rule severity: `"error"` blocks CI; `"warn"` reports only; `"off"` disables
- Override individual rules: `"rules": { "suspicious": { "noExplicitAny": "error" } }`

### organizeImports

- `"organizeImports": { "enabled": true }` — sort and deduplicate imports on format
- Runs automatically with `biome format --write` and `biome check --write`

### Files & Ignores

- `files.ignore` for paths to skip entirely: `["dist", ".next", "node_modules", "*.generated.ts"]`
- `files.include` to whitelist (rarely needed; prefer ignore)
- Prefer `files.ignore` over per-file `// biome-ignore` comments

### overrides

- Use `overrides` to relax rules for test files:
```json
{
  "overrides": [
    {
      "include": ["**/*.test.ts", "**/*.spec.ts", "**/__tests__/**"],
      "linter": {
        "rules": {
          "suspicious": { "noExplicitAny": "off" }
        }
      }
    }
  ]
}
```
- Use `overrides` for generated files with different formatting needs

### CI Integration

- `biome ci` — check + no writes; exits non-zero on any issue; use in CI pipelines
- `biome check --write` — fix + format in one pass; use in pre-commit hooks
- `biome format --write` — format only
- `biome lint --write` — lint + auto-fix only
- `biome check` (no `--write`) — dry-run check; reports issues without writing

### VSCode Integration

- Install `biomejs.biome` extension
- Set as default formatter: `"editor.defaultFormatter": "biomejs.biome"`
- `"editor.formatOnSave": true` for auto-format
- `"editor.codeActionsOnSave": { "source.organizeImports.biome": "explicit" }` for import sorting on save

### Replacing ESLint + Prettier

- Remove `eslint`, `eslint-config-*`, `prettier`, `@prettier/*` from `package.json`
- Remove `.eslintrc.*`, `.prettierrc.*`, `.eslintignore`, `.prettierignore`
- Copy ignore patterns from `.eslintignore`/`.prettierignore` → `biome.json` `files.ignore`
- Map ESLint rules to Biome equivalents; check [biomejs.dev/linter/rules](https://biomejs.dev/linter/rules)
- `biome migrate eslint` — auto-converts `.eslintrc` to Biome config (Biome 1.5+)
- `biome migrate prettier` — auto-converts `.prettierrc` to Biome formatter config

### Anti-patterns

- Mixing Prettier + Biome formatters — conflicting rules, double-formatting
- `// biome-ignore lint: reason` without specific rule name — use `// biome-ignore lint/category/ruleName: reason`
- Ignoring entire files with `biome-ignore` instead of scoped `overrides`
- Missing `organizeImports.enabled` — imports won't sort
- `biome format` in CI without `--write=false` / using `biome ci` instead
- `files.ignore` missing `dist`, `node_modules`, `*.generated.*`
- No `$schema` — loses IDE autocomplete and validation
- `nursery` rules enabled in `"error"` severity in CI — nursery rules are unstable

## Output Format

Group by file. Use `file:line` format (VS Code clickable). Terse findings.

```text
## biome.json

biome.json:1 - missing $schema
biome.json:8 - organizeImports not enabled
biome.json:15 - files.ignore missing "dist" and ".next"
biome.json:22 - no overrides for test files

## package.json

package.json:14 - prettier still present → remove after Biome migration
package.json:15 - eslint still present → run biome migrate eslint

## .vscode/settings.json

✓ pass
```

State issue + location. Skip explanation unless fix non-obvious. No preamble.
