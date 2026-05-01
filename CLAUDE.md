# Dotfiles Project Guidelines

This repo contains shell config, Neovim config, tmux/zellij, CLI tooling, and `bin/` scripts. It is not a frontend project — do not assume React/TS/Node conventions.

## Layout

- `bin/` — standalone CLI scripts (mixed bash/zsh, check shebang per file)
- `config/zsh/` — zsh configuration; entrypoint is `config/zsh/zshrc`
  - `config/zsh/completion/` — per-command completion files
- `config/nvim/lua/` — Neovim config
  - `plugins/` — plugin specs (lazy.nvim)
  - `options.lua`, `keymaps.lua`, `config/`, `nvconfig.lua`
- `config/tmux/`, `config/zellij/`, `config/starship.toml`, `config/zed/`, `config/aerospace/`, etc.
- `.ai/` — Claude-specific helpers: `statusline.sh`, `guidelines/`, `skills/`, `subagents/`

## Shell Scripts

- Always read the shebang before writing shell-expansion code. `bin/` scripts are a mix of `#!/usr/bin/env bash` and zsh.
- A script cannot change its parent shell's cwd. Any `bin/` command that needs to `cd` after running must be wrapped with a zsh function in `config/zsh/alias.sh`. Before implementing any navigation logic in a `bin/` script, determine upfront whether a cwd change is needed — if yes, the wrapper is mandatory from the start. Do not attempt a bin-only implementation first and fix it after user pushback.
- `config/zsh/alias.sh` uses `#!/bin/zsh` — treat all expansion code as zsh.
- In bash heredocs, use a quoted delimiter (`<<'EOF'`) when the body contains literal `$` characters. An unquoted delimiter causes command substitution on any `$(...)` inside the body.
- Process name detection in `bin/` scripts: do not rely on `comm=` alone. Node-based CLIs (e.g. `gemini`) run as `node /path/to/tool` — `comm=` gives "node", not "gemini". Use `ps -o args=` and check basenames of both argv[0] and argv[1].
- When extracting fields from git output with `awk`, verify the field number against real command output before writing the expression — git output formats vary by subcommand and flag.
- Do not add subprocess calls (e.g. `$(brew --prefix foo)`, `$(command -v foo)`) to `exports.sh` or any file sourced unconditionally at startup. Hardcode paths or gate behind `[[ -f ... ]]` checks.
- When adding a function that fires on shell events, register it in the same task: `chpwd_functions+=fn_name`, `precmd_functions+=fn_name`, or `preexec_functions+=fn_name`.
- When a parameter-expanded variable inside a zsh `[[ =~ ]]` pattern already contains a capture group (e.g. `(feat|fix|...)`), wrapping it in another `(...)` shifts all subsequent `$match[N]` indices. Expand mentally and count groups before referencing `$match[N]`.

## Zsh Completions — Registration Required

- New completion files under `config/zsh/completion/` MUST be added to the `SOURCE` array in `config/zsh/zshrc` in the same task. A file that is never sourced has zero effect.
- After creating or moving a completion file, the final tool call before closing MUST be a grep of the `SOURCE` array in `config/zsh/zshrc` confirming the new path is present.
- When modifying/moving/removing a completion file, update the `SOURCE` array in the same task.
- Short completions for git aliases can live directly in `config/zsh/git.sh` rather than as separate files.

## Neovim (Lua)

- Read `plugins/`, `options.lua`, and `keymaps.lua` before editing any one of them — changes often interact.
- Plugin specs use lazy.nvim conventions; co-locate plugin options inside the spec's `opts` or `config`.
- Snacks picker: layout keys are `layout.preview`, `layout.list`, `layout.input`. These interact — inspect current state before editing. When making multiple layout edits across image-feedback turns, re-read `snacks.lua` at the start of each turn before applying the next change.
- Snacks picker data: use `items=` (not `finder=`) for pre-built Lua tables. `finder=` with a table crashes on numeric fields (e.g. `tab=1`) because Snacks calls `vim.split()` on every field value.
- Autocmd deduplication: every `nvim_create_autocmd` must be wrapped in `nvim_create_augroup(name, { clear = true })`. Without it, `:Lazy reload` registers silent duplicates.
- Do not set the same option via both `vim.o.*` and `vim.opt.*`. `vim.o.*` before `vim.opt.*` for the same key is silently dead code. Use `vim.opt` consistently.
- Before adding any plugin to `config/nvim/lua/plugins/`, grep `plugins/` for an existing spec providing the same capability.

## Starship

- When writing `[custom.*]` `when` conditions that compare git paths (e.g. `git rev-parse --show-toplevel` vs a target dir), resolve both sides to absolute paths before comparing. Relative vs absolute paths cause false matches in subdirectories.
- Worktree detection specifically: `git rev-parse --git-dir` returns an absolute path, but `--git-common-dir` returns a relative path when inside a subdirectory. Always resolve both via `$(cd "$(git rev-parse --git-dir)" && pwd)` before comparing — direct string comparison will produce false positives in subdirectories.

## Deployment

- Dotfiles worktrees break live testing: `~/.config/nvim`, `~/.config/mise`, etc. are symlinks into the master checkout. Neovim and mise follow the symlink to the main tree, not the worktree. Work on the active branch directly for dotfiles changes.
- bunsen deployment: symlinks are declared in `dotfiles.config.ts` (`@g4rcez/bunsen`). When adding `config/<tool>/`, check `dotfiles.config.ts` for a needed entry — missing entries mean the config never reaches `~/.config/`.
- Mise tool versions must be pinned explicitly (e.g. `"pipx:nvr==2.5.1"`), never `"latest"`.

## Claude Code Hooks and Skills

- When creating a Claude Code hook script, update `~/.claude/settings.json` in the same task to register it.
- Before editing `~/.claude/settings.json`, read the full file first — don't clobber existing entries.

## Claude Tool Environment Quirks

- `cat` is aliased to `bat` in this shell and mangles paths and emits OSC-8 hyperlinks when called via Bash. Use the `Read` tool (or `command cat`) instead of `cat`.
- `ls` output is colorized and can include hyperlink escapes; use `command ls` or the `Glob` tool when parsing.
- Zed config: `~/.config/zed` should be a symlink to `config/zed/`. If a Zed edit isn't applying, verify with `ls -la ~/.config/zed` before looking elsewhere.
- Karabiner/Aerospace boundary: Karabiner handles modifier transforms and tap-vs-hold logic (e.g. `caps_lock` → Hyper, tap=Escape) that Aerospace cannot replicate. Before any Karabiner→Aerospace migration, audit which bindings require Karabiner vs which are plain window-management hotkeys.

## Commit Style

- Follow existing commit style in `git log` (prefix like `chore:`, `feat:`, `feat(bin):`, etc.). Focus on the "why" not the "what".
