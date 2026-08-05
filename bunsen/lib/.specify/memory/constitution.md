<!--
Sync Impact Report:
- Version: 0.0.0 → 1.0.0
- Modified Principles: N/A (Initial version)
- Added Sections: All core principles and governance rules
- Removed Sections: N/A
- Templates requiring updates:
  ✅ plan-template.md: Constitution Check section aligned
  ✅ spec-template.md: Requirements and success criteria aligned
  ✅ tasks-template.md: Task organization and testing discipline aligned
- Follow-up TODOs: None
-->

# Bunsen Constitution

## Core Principles

### I. Strict Type Safety

TypeScript MUST be used with strict mode enabled at all times. All function inputs and outputs MUST be explicitly typed with no implicit `any` types. Zod schemas MUST mirror all TypeScript types for runtime validation. Type inference is acceptable only when the type is immediately obvious from the assignment.

**Rationale**: Strict typing catches errors at compile time, provides superior IDE autocomplete, and ensures runtime validation aligns with compile-time contracts. This is non-negotiable for a configuration management tool where user input drives critical system operations.

### II. Runtime Without Build Steps

All TypeScript code MUST run directly via Bun's native TypeScript support with zero build, transpilation, or compilation steps. No intermediate JavaScript artifacts. Configuration files MUST be loadable at runtime using dynamic imports.

**Rationale**: Bun's native TypeScript execution eliminates build complexity, reduces startup time, and simplifies the developer experience. Build steps are overhead that provides no value when the runtime natively supports TypeScript.

### III. Idempotent Operations

All mutating operations (symlinks, file writes, shell injections) MUST be safe to execute multiple times without unintended side effects. State MUST be tracked persistently to enable operation verification and future rollback.

**Rationale**: Users will run `bunsen apply` repeatedly during dotfiles iteration. Operations must be deterministic and non-destructive to build user trust and enable safe experimentation.

### IV. Security First

All user-provided paths MUST be validated and resolved through a security layer that prevents directory traversal attacks. Environment variable expansion MUST happen after validation. Symlinks MUST NOT be followed during path validation. No shell command execution without explicit user configuration.

**Rationale**: Dotfiles management requires filesystem access and shell integration. Security vulnerabilities could grant arbitrary filesystem access or command execution.

### V. Minimal Comments, Maximum Types

Code MUST be self-documenting through explicit type annotations and descriptive naming. Comments are ONLY permitted when the logic is inherently non-obvious or when documenting security-critical validation. Type signatures replace what would otherwise be parameter documentation.

**Rationale**: In a strictly typed codebase, types serve as inline documentation. Comments decay and lie; types are enforced by the compiler and always reflect current reality.

### VI. Code Structure Follows Dependency Flow

Module organization MUST reflect the architectural dependency flow: CLI → Config Loader → Validation → Managers/Generators → State Tracker. File names MUST clearly indicate their role (e.g., `resolver.ts` for path resolution, `conflict.ts` for conflict handling).

**Rationale**: Consistent structure reduces cognitive load and makes the codebase navigable. New contributors should be able to predict file locations based on architectural understanding.

## Constraints

### ESM Only

Project uses ESM modules exclusively. All imports MUST use `.js` extensions per TypeScript ESM conventions (even when importing `.ts` files). No CommonJS compatibility shims.

### No External Dependencies for Core Operations

File system operations MUST use native Node.js `node:fs` modules. Shell spawning MUST use Bun's native `Bun.spawn()` API. Terminal colors MUST use native ANSI escape codes. Only external dependencies allowed: core runtime (Bun), schema validation (Zod), CLI framework (Commander), user-facing libraries (karabiner.ts, yaml).

### Explicit Error Messages

All validation errors MUST include the file path, specific violation, and actionable remediation. Use Zod's error formatting capabilities. Generic error messages are forbidden.

## Testing Requirements

Testing MUST use Bun's native test runner. Unit tests MUST mock filesystem operations. Integration tests MUST use temporary directories for real filesystem operations. Test fixtures MUST be minimal and focused. Tests are OPTIONAL unless explicitly requested in feature specifications.

## Governance

Constitution supersedes all other practices and templates. All code reviews and pull requests MUST verify compliance with these principles. Any deviation MUST be explicitly justified in the implementation plan's Complexity Tracking table.

Amendments require:
1. Documentation of the proposed change and rationale
2. Analysis of impact on existing codebase
3. Update of dependent templates and documentation
4. Approval via pull request review

Complexity violations (e.g., introducing implicit types, build steps, or excessive comments) MUST be justified with technical necessity and alternatives considered. "Easier" or "faster" are insufficient justifications without demonstrating that the principle's benefit is outweighed.

Use `CLAUDE.md` for runtime development guidance and architectural context.

**Version**: 1.0.0 | **Ratified**: 2025-12-16 | **Last Amended**: 2025-12-16
