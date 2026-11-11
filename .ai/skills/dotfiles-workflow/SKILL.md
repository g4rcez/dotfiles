---
name: dotfiles-workflow
description: Specialist for this dotfiles repo (Rex terminal, zsh/bash, bin/ scripts, Neovim, git worktrees, AI CLI tooling). Use whenever a task touches bin/, config/zsh, config/nvim, config/rex, tests/shell, bin/ai (sessions, monitor, statusline), aicommit/commit splitting, worktrees, a Neovim code-review plugin, a Rex cockpit/extension, curl+jq helpers, or OS control scripts. Also use when the user asks how to improve or speed up their keyboard-driven workflow, even if they do not say "dotfiles". It routes to per-area references, closes a verify loop with the repo's own checks, and ends with a short list of workflow findings.
---

# Dotfiles workflow

This repo is a keyboard-centric terminal setup. The active terminal and multiplexer is Rex. tmux and zellij are legacy. `AGENTS.md` in the repo root holds the hard rules (shebangs, completions registration, Rex sandbox limits, git rules). This skill does not repeat them. It adds three things: where to look, how to prove a change works, and what to suggest next.

## 1. Route: read only the reference for the area you touch

| Area of the task | Read first |
|---|---|
| `bin/*`, `config/zsh/*`, curl+jq, OS control, Go/Rust/Bun CLIs | `references/shell-and-bin.md` |
| Rex, `bin/ai` sessions/monitor/statusline, cockpit, AI session visibility | `references/rex-and-sessions.md` |
| `config/nvim/*`, a Neovim plugin, the code-review loop | `references/neovim.md` |
| Commits, `aicommit`, splitting work, worktrees, rebase/merge | `references/git-and-commits.md` |
| Proving a change works, which check to run | `references/verify.md` |
| "What should I build next?", workflow improvements | `references/backlog.md` |

Several areas can apply to one task. Read each reference that applies and no more: they are short, but unrelated ones waste context.

Existing skills cover language details. Load them for the details and do not duplicate them here: `shell-bash`, `shell-zsh`, `neovim-lua`, `worktree-workflow`.

## 2. Build: reuse before writing

1. Search `bin/`, `config/zsh/`, and `config/rex/extensions/` for something that already does most of the job. This repo has many small tools (`ai`, `workstate`, `task-checkpoint`, `repo-check`, `rex-fzf-*`) and a new script that overlaps one is a defect.
2. Prefer the platform and the dependencies already in `config/mise/config.toml`. A new dependency needs the user's approval and a supply-chain note (see `AGENTS.md`).
3. A new tool follows the pattern of its nearest neighbor: same shebang style, same `source .../lib/dotfiles-shell.sh`, same fzf theme through `config/zsh/fzf.sh`.
4. A script cannot change its parent shell's cwd. Decide first whether the tool needs a zsh wrapper in `config/zsh/alias.sh`.

## 3. Verify loop: do not report "done" before a check passes

Reasoning: the user's biggest complaint is that the AI stops at "it should work". The repo already ships its checks, so use them.

1. After each change, pick the smallest matching check from `references/verify.md` and run it.
2. If it fails, read the failure, fix the cause, and run it again. Do not weaken the assertion or skip the check.
3. Run each check you create or change. Run the wider suite (`bash tests/shell/run.bash`) only when the change touches shared code (`bin/lib/`, `config/zsh/fzf.sh`, `exports.sh`). `AGENTS.md` says to ask before running full suites, so ask once per task, not per run.
4. If no check covers the change, say so in the final report. That gap is a candidate workflow finding.
5. If a needed tool is missing (for example `luacheck`), do not install it. State the gap and ask the user to install it.

## 4. Workflow findings: advise quietly, never act

At the end of a dotfiles task, add a section named "Workflow findings" with at most 3 items. Skip the section if there is nothing real to say. Each item has:

- **Friction:** what cost time or risk in this task, observed and not guessed.
- **Fix:** the smallest change that removes it.
- **Cost:** rough size (minutes, one file, new dependency).

Rules: do not implement any finding without the user's go-ahead. Do not pad the list. Prefer findings that came from this task over generic advice. `references/backlog.md` holds the known, larger items, so link to it and do not restate it.

## 5. Final report

Follow the `AGENTS.md` format: summary, changed paths, checks run (with results), risks, skipped checks, unrelated findings, next steps. Add "Workflow findings" after it.
