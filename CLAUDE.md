## Dotfiles Project Conventions

- This repo is shell scripts, zsh config, and tool configs — no JS/TS. Testing rules from global CLAUDE.md do not apply here.

## Claude Code Hooks

- All hooks live in `config/claude/hooks/` (version-controlled). Reference them as `$HOME/dotfiles/config/claude/hooks/<script>` in `~/.claude/settings.json`. Never copy them to `~/.claude/hooks/`.
- When creating a new hook, create the script in `config/claude/hooks/` AND update `~/.claude/settings.json` in the same task.

## Zsh

- Any variable that holds a shell command string (e.g. `AI_QUERY_COMMAND`) must be expanded with `${=VAR}` in zsh, not `$VAR`, to force word splitting.
- Some `bin/` scripts use bash (`#!/usr/bin/env bash`), not zsh. Check the shebang before using zsh-isms like `${=VAR}` — for bash, use `eval exec "$cmd"` instead.
- New `bin/` tools should have a matching zsh completion file in `config/zsh/completion/` following the `_ai.zsh` pattern.

## Terminal / Image Rendering

- Target environment: Ghostty terminal + tmux. Use `chafa --passthrough auto` for image rendering in `bin/lessfilter.sh`. `allow-passthrough on` is already set in tmux config. Do not suggest iTerm2 or WezTerm image protocols.

## AI Skills (`config/.ai/skills/`)

- When editing skill files, target 20–30% token reduction. Keep examples and frontmatter trigger conditions intact. Do not restructure or rewrite — light editing pass only.
