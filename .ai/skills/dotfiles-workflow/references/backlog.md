# Backlog: known pain points and candidate tools

Source: the user's own statement of intent (2026-11-10). These are proposals. None is approved or built. Before working on one, confirm scope with the user and re-check that nobody has built it since (grep `bin/`, `config/nvim/lua/`, `config/rex/extensions/`).

Order is by the user's stated priority: review loop, tests loop, session visibility.

## 1. Code-review loop in Neovim

- **Pain:** reviewing AI-written diffs outside the editor, then retyping feedback to the AI.
- **Idea:** a local Neovim module that opens a diff (reuse `codediff`/`diffview`), collects line comments, and sends them to the AI pane with `rex send`. See the shape in `references/neovim.md`.
- **Smallest first step:** a command that exports the current buffer's `haunt.nvim` annotations as a markdown block and copies or sends it. Check if `haunt` can enumerate annotations before writing anything.
- **Risks:** key conflicts, picker layout rules (Snacks), diff plugin API changes.
- **Check:** headless test for the export function with literal input and output.

## 2. Verify loop for AI changes

- **Pain:** the AI stops at "it should work".
- **Done in this skill:** the verify loop and the check table (`references/verify.md`).
- **Candidate improvements:**
  - A `bin/` entry that maps changed paths to checks (a thin layer on `bin/repo-check --dry-run`) so the AI and the user run the same command.
  - A hook that runs the matching check after edits (the repo has a `format-on-edit` test, so check how that hook is wired first).
  - Missing static analysis: `luacheck` is not installed (`shellcheck` is, since 2026-11-10). Needs the user to install it.
  - Missing Rex extension test: no way to run an extension headless.

## 3. Live view of AI sessions

- **Pain:** not seeing which sessions work, wait, or finished.
- **Exists:** `bin/ai sessions|monitor|--_statusline`, cockpit sidebar and panel (see `references/rex-and-sessions.md`).
- **Candidate improvements, in order of value:**
  1. A "needs you" state that separates "done" from "waiting for input".
  2. The sidebar shows all agents per session, not the first one.
  3. A notification on working to done (check `bin/claude-notify` first).
  4. A history view built from transcript JSONL (what each session changed). Lower priority: `ai-memory` covers part of it.
- **Check:** extend `tests/shell/ai-statusline-test.bash`. Use a fake `rex` on `PATH` that prints literal JSON.

## 4. Cleanup candidates seen while reading (low priority, confirm first)

- Legacy tmux and zellij scripts still sit in `bin/` and `config/`. `AGENTS.md` says they are reference only. Removing them is the user's decision.
- `bin/ai` carries both tmux and Rex backends in one 870-line file. Splitting it would help, but only after the cockpit work lands.
- `worktree-workflow` skill still describes tmux sessions.

When you raise one of these as a "Workflow finding", state the evidence (file and what you saw) and the cost.
