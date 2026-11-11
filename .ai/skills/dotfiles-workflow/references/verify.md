# Verify: which check proves which change

Run the smallest check that covers the change. Facts below were read from the repo; re-check them if a path no longer exists.

## Checks that exist today

| Change | Check | Notes |
|---|---|---|
| Any `bin/*` or shell file | `bash tests/shell/syntax-test.bash` | Walks every tracked and untracked file, validates shebangs and syntax for bash and zsh files. |
| Bash files you changed | `shellcheck <file>` | Pinned in `config/mise/config.toml`. It does not read zsh: use `zsh -n` for zsh files. Judge warnings against the file's existing style (`SC1091` and intentional `VAR=` patterns exist today). Report only new findings from your change. |
| `bin/ai` or statusline | `bash tests/shell/ai-statusline-test.bash` | Currently modified in the working tree. Read it before extending it. |
| fzf picker in `bin/` | `bash tests/shell/fzf-layout-test.bash` | Fails if a `bin/` script calls `fzf` without sourcing `config/zsh/fzf.sh`. |
| Worktree helpers | `bash tests/shell/worktree-test.bash` | |
| Git completion | `bash tests/shell/git-completion-test.bash` | |
| Other known areas | `tests/shell/<area>-test.bash` | `gh-fzf`, `skillspicker`, `pre-push`, `install`, `docs`, `workflows-cache`, `format-on-edit`, `context-lite-doctor`, `repo-check`. |
| Whole shell suite | `bash tests/shell/run.bash` | Runs every `tests/shell/*-test.bash`. Ask before running it. |
| Neovim Lua | `nvim --headless -u NONE -l config/nvim/tests/smoke.lua` | Also `contextual_completion.lua` and `mention_ls.lua` in the same folder. |
| Neovim Lua format | `stylua --check <file>` | `stylua` is installed through mise. |
| Rex extension (`config/rex/extensions/*.lua`) | `nvim --headless -u NONE -c 'lua assert(loadfile("<path>"))' -c q` | Syntax check only. It does not run the extension. It proves the file parses and nothing else. |
| Repo-wide canonical checklist | `bin/repo-check --dry-run`, then `bin/repo-check` | Detects Cargo, Go, and shell/nvim tests. Use `--dry-run` first to see what it would run. |
| Dotfiles health | `bin/dotfiles-doctor` | Reports ok/warn/fail for the repo setup. |

## Gaps (report these, do not hide them)

- `luacheck` is not installed. Ask the user to install it if a task needs Lua static analysis.
- No automated check runs a Rex extension. After a syntax check, tell the user what to test by hand (open the action in Rex).
- Neovim plugin specs have no load test beyond `smoke.lua`. A new plugin needs its own `config/nvim/tests/<name>.lua` (headless, `-u NONE`, literal expectations).
- UI behavior in Neovim (a picker, a diff view) is not covered. Say what was not exercised.

## Rules for new tests

Follow the "Tests and diagnostics" section of `AGENTS.md`. Local additions:

- New shell tests go in `tests/shell/<area>-test.bash` and use `tests/shell/test-helper.bash` (`make_temp_dir`, `fail`). The runner picks them up by the `-test.bash` suffix.
- Reproduce a bug in a failing test before the fix, and confirm it fails for the right reason.
- Use temp dirs and fake `PATH` entries for external tools (`rex`, `tmux`, `git`) only at the true boundary. Do not mock your own functions.
- Do not add a test framework. The shell tests and headless Neovim scripts are the framework.
