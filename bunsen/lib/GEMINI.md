# Bunsen Context

## Project Overview

**Bunsen** (@g4rcez/bunsen) is a declarative dotfiles manager built with TypeScript and designed to run on the **Bun** runtime. It draws inspiration from NixOS flakes, aiming to provide a single source of truth (`dotfiles.config.ts`) for managing:

*   **Symlinks:** Efficiently linking dotfiles with backup and conflict resolution strategies.
*   **Packages:** Unified installation across Homebrew, APT, Pacman, and DNF.
*   **Environment Variables:** Shell-agnostic environment variable management and injection.
*   **Karabiner:** TypeScript-based generation of complex keyboard rules.
*   **Espanso:** Declarative text expansion configuration.
*   **Window Managers:** Integration with AeroSpace and Rectangle.

**Key Characteristic:** It leverages Bun's native TypeScript support, meaning **no build step** is required for development or execution.

## Architecture & Data Flow

The application follows a linear execution flow:

1.  **CLI Entry (`src/cli/index.ts`):** Parses commands using `commander`.
2.  **Config Loading (`src/core/config/loader.ts`):** Dynamically imports `dotfiles.config.ts`, handling TypeScript natively.
3.  **Validation (`src/core/config/schema.ts`):** Validates the user configuration against Zod schemas.
4.  **Execution (`src/cli/commands/*.ts`):** Orchestrates the requested operation (apply, status, etc.).
    *   **Symlink Manager:** Handles file linking and backups.
    *   **Generators:** Produces config files for external tools (Karabiner, Espanso, Shell Env).
    *   **State Tracker:** Records actions to `~/.config/bunsen/state.json` to ensure idempotency and enable rollback/status checks.

## Key Files & Directories

*   **`bin/bunsen`**: The production binary entry point.
*   **`src/cli/`**: Contains the CLI logic and command implementations.
    *   `index.ts`: Main entry point.
    *   `commands/`: Individual command logic (init, apply, status, etc.).
*   **`src/core/`**: Core business logic.
    *   `config/`: Configuration loading, types, and Zod schemas.
    *   `generators/`: Logic for generating external configuration files.
    *   `state/`: State tracking and persistence logic.
    *   `symlink/`: Symlink creation, conflict resolution, and path management.
*   **`src/api/`**: Public API exported for use in `dotfiles.config.ts`.
*   **`examples/`**: Reference configurations for users.
*   **`dotfiles.config.ts`**: The user's configuration file (not part of the source, but the central data input).

## Development Workflow

Since Bunsen uses Bun, standard Node.js workflows are slightly modified.

### Running the CLI
Execute the CLI directly from the source without compilation:

```bash
# General syntax
bun run bunsen -- <command> [flags]

# Examples
bun run bunsen -- init
bun run bunsen -- apply --dry-run
bun run bunsen -- status
```

### Testing
Run the test suite using Bun's native test runner:

```bash
# Run all tests
bun test

# Run with coverage
bun test --coverage
```

### Code Quality
Format code using Prettier:

```bash
bun run format
```

## Core Concepts & Conventions

*   **Idempotency:** All operations should be idempotent. The `status` command and internal logic rely on `~/.config/bunsen/state.json` to track what Bunsen has modified. Always check this state before performing destructive actions.
*   **Type Safety:** Use Zod for runtime validation of all user inputs and configurations.
*   **Native TypeScript:** Do not introduce build steps. Code should be valid TypeScript that Bun can execute directly. Use `.ts` extensions.
*   **Path Resolution:** Always resolve paths securely using `src/core/symlink/resolver.ts` to handle `~`, env vars, and prevent directory traversal.
*   **Dry Run:** All mutating commands must support a `--dry-run` flag that logs intended actions without modifying the filesystem.

## Common Tasks

### Adding a New Generator
1.  Define the configuration type in `src/core/config/types.ts`.
2.  Add Zod validation in `src/core/config/schema.ts`.
3.  Create the generator logic in `src/core/generators/<name>.ts`.
4.  Expose any necessary helper functions in `src/api/`.
5.  Integrate into `src/cli/commands/apply.ts`.

### Modifying State Tracking
If adding a new type of managed resource:
1.  Update the state interface in `src/core/state/types.ts` (if applicable).
2.  Ensure `src/core/state/tracker.ts` correctly records and retrieves the new resource type.
