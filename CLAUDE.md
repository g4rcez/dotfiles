# Dotfiles Project Guidelines

This repo contains shell config, Neovim config, tmux/zellij, CLI tooling, and `bin/` scripts. It is not a frontend project — do not assume React/TS/Node conventions.

## Layout

- `bin/` — standalone CLI scripts (mixed bash/zsh, check shebang per file)
- `config/zsh/` — zsh configuration; entrypoint is `config/zsh/zshrc`
  - `config/zsh/completion/` — per-command completion files
- `config/nvim/lua/` — Neovim config
  - `plugins/` — plugin specs (lazy.nvim)
  - `options.lua`, `keymaps.lua`, `config/`, `nvconfig.lua`
- `config/tmux/`, `config/zellij/`, `config/starship/`, etc.

## Shell Scripts

- Always read the shebang before writing shell-expansion code. `bin/` scripts are a mix of `#!/usr/bin/env bash` and zsh.
- zsh: multi-word command strings must use `${=VAR}` (explicit word splitting). Bare `$VAR` in zsh does not split on spaces.
- bash: use `eval exec "$cmd"` for multi-word command strings. `${=VAR}` is zsh-only.
- A script cannot change its parent shell's cwd. Any `bin/` command that needs to `cd` after running must be wrapped with a zsh function in `config/zsh/alias.sh`.
- `config/zsh/alias.sh` starts with `#!/bin/bash` but is sourced by zsh — treat it as zsh (the shebang is wrong/ignored).

## Zsh Completions — Registration Required

- New completion files under `config/zsh/completion/` MUST be added to the `SOURCE` array in `config/zsh/zshrc` in the same task. A file that is never sourced has zero effect.
- When modifying/moving/removing a completion file, update the `SOURCE` array in the same task.
- Short completions for git aliases can live directly in `config/zsh/git.sh` rather than as separate files.

## Neovim (Lua)

- Read `plugins/`, `options.lua`, and `keymaps.lua` before editing any one of them — changes often interact.
- Plugin specs use lazy.nvim conventions; co-locate plugin options inside the spec's `opts` or `config`.
- Snacks picker: layout keys are `layout.preview`, `layout.list`, `layout.input`. These interact — inspect current state before editing.

## Starship

- When writing `[custom.*]` `when` conditions that compare git paths (e.g. `git rev-parse --show-toplevel` vs a target dir), resolve both sides to absolute paths before comparing. Relative vs absolute paths cause false matches in subdirectories.

## Claude Code Hooks and Skills

- When creating a Claude Code hook script, update `~/.claude/settings.json` in the same task to register it.
- Before editing `~/.claude/settings.json`, read the full file first — don't clobber existing entries.

## Claude Tool Environment Quirks

- `cat` is aliased to `bat` in this shell and mangles paths and emits OSC-8 hyperlinks when called via Bash. Use the `Read` tool (or `command cat`) instead of `cat`.
- `ls` output is colorized and can include hyperlink escapes; use `command ls` or the `Glob` tool when parsing.

## Commit Style

- Follow existing commit style in `git log` (prefix like `chore:`, `feat:`, `feat(bin):`, etc.). Focus on the "why" not the "what".
