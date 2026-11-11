# Git, AI commits, worktrees

`AGENTS.md` rules apply here and are strict: do not commit, open PRs, rewrite history, or force-push unless the user asks. Never use `git add -A`, `git add .`, `git reset --hard`, `git checkout .`, `git clean -fd`, `git stash`, or `--no-verify`. Stage only requested paths.

## Tools that exist

| Tool | Job |
|---|---|
| `bin/aicommit` | Generates a conventional commit message from `git diff --staged` with the AI provider in `$AI_QUERY_COMMAND` and the prompt in `prompts/aicommit-script.txt`. `-e` opens the editor with the message. `-c` commits directly. |
| `commit ai [hint] [-- git-commit-args] [--push push-args]` (`bin/commit`) | Splits all changed paths into one commit per reason. AI groups the paths (`prompts/aicommit-split.txt`), it asks before making more than one commit, stages each group by explicit path, and lets the hooks run (it never uses `--no-verify`). If the AI answer is not a valid split, it makes one commit. Pushes once at the end. Covered by `tests/shell/commit-ai-test.bash`. |
| `commit write` (`bin/commit`) | Prints an AI commit message for the whole diff. `AICOMMIT_CACHED=1` limits it to the index. |
| `bin/commit` | Wrapper around `git commit` with `--no-verify` and `--branch` prefix options. Subcommands (`commit --commands`): `wip`, `staged`, `scope`, `fake` and fixed-message commits such as `commit docs`. A message equal to a subcommand name needs `commit -- docs`. |
| `bin/fzf-git`, `bin/git-fzf-preview.sh`, `bin/git-branch.sh` | fzf views for branches and commits. |
| `bin/gh-fzf`, `bin/gh.runs`, `bin/workflows` | GitHub PRs, runs, and workflow lookups. |
| `bin/gitx`, `bin/ghpr`, `bin/ghx` | Git and GitHub helper families (`<command> --commands` lists the subcommands). `gitx worktree-clean` lists linked worktrees and removes the marked ones. `config/zsh/git.sh` keeps only aliases, forgit wrappers and completion helpers. |
| `workmux` (aliased as `worktree` in `alias.sh`) | Worktree plus session management. Config in `config/workmux`. |
| `bin/task-checkpoint` | Writes an untracked checkpoint inside `.git` of the current worktree (intent plus next validation command). |
| `bin/workstate` | Summary of repo state across roots. |

The `worktree-workflow` skill describes an older tmux-based flow. Rex is active now, so use it for the idea and verify the commands against `workmux` before quoting them.

## Splitting work into several commits (what the user wants)

The user runs AI at the CLI to split a dirty tree into multiple commits. When asked to help with this, the order is:

1. Read `git status` and `git diff --stat`. Group changes by one reason each (feature, fix, refactor, chore). Unrelated files never share a commit.
2. Propose the groups with their paths and a message each, and wait for approval. Commits are outward-facing in effect, and `AGENTS.md` forbids committing without being asked.
3. When approved: stage by explicit path (`git add -- <paths>`). For files that mix two reasons, use `git add -p` equivalents the harness supports, or ask the user to stage hunks. Do not use interactive flags.
4. Message style follows `git log`: prefixes such as `feat:`, `fix:`, `chore:`, `feat(bin):`, `feat(zsh):`, `feat(nvim):`. Focus on why, not what. Pre-commit hooks must pass. Never bypass them.
5. After each commit run `git show --stat HEAD` and report it.

If `aicommit` fails with "AI_QUERY_COMMAND is not set", that is an environment gap. Report it. Do not hardcode a provider.

## Worktrees, rebase, merge

- Dotfiles worktrees break live testing, because `~/.config/*` symlinks point into the main checkout. For dotfiles changes, work on the active branch directly (see `AGENTS.md` Deployment section).
- Other repos: one worktree per branch is fine. Check with `git worktree list` before creating one.
- Rebase and merge change history. Describe the exact command and its effect first. Run it only on request. Never rebase a branch that is already pushed unless the user says so.

## Verify

`bash tests/shell/worktree-test.bash` and `bash tests/shell/git-completion-test.bash` for helper changes. Test git helpers in a temp repo (`git init` in a temp dir), never in the user's repo.
