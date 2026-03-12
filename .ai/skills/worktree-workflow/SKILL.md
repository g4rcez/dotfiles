---
name: worktree-workflow
description: Use when the user wants to work on a new feature in isolation, create a worktree, or manage parallel development branches. Describes the worktree + tmux session workflow.
---

# Worktree Workflow

This project uses git worktrees for isolated feature development. Each worktree gets its own tmux session.

## Core Commands

### Create a worktree for a new branch

```bash
worktree add <branch-name> [base-branch]
```

Examples:
- `worktree add feature/auth` — creates from current HEAD
- `worktree add feature/auth main` — creates from main
- `worktree add feature/auth origin/develop` — creates from remote branch

Worktrees are stored at `~/.tmp/git/<repo-name>/<branch-name>`.

### Open a worktree in a tmux session

```bash
worktree mux
```

Presents an fzf picker of all worktrees; creates or attaches to a tmux session named after the branch.

### List worktrees with status

```bash
worktree overview
```

Prints a table: branch | tmux session (●/○) | dirty file count | ahead/behind upstream.

### Navigate to a worktree

```bash
cd $(worktree cd <branch-name>)
```

### Remove a worktree

```bash
worktree remove <branch-name>
```

### Interactive list with preview

```bash
worktree list
```

fzf picker showing git log or live tmux pane preview. `Ctrl-D` to delete.

## Typical Flow

1. `worktree add feature/my-task main` — create isolated worktree
2. `worktree mux` — pick the new worktree and open a tmux session
3. Inside the session: run `claude` to start an AI session in that worktree
4. When done: `worktree remove feature/my-task`

## AI Commit Helpers

- `wip.ai()` — stages all, generates commit message via Gemini, commits + pushes
- `wip.cc()` — same but uses Claude CLI (`claude -p ...`) instead of Gemini
- `aicommit` — just generate the message (Gemini), copies to clipboard
- `aicommit.cc()` — same but uses Claude CLI
