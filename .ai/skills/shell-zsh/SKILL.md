---
description: Review shell scripts and zsh configs for correctness, safety, and idiomatic style
argument-hint: <file-or-pattern>
---

# Shell / Zsh Review

Review these files for compliance: $ARGUMENTS

Read files, check against rules below. Output concise but comprehensive—sacrifice grammar for brevity. High signal-to-noise.

## Rules

### Quoting

- Always double-quote variables: `"$var"` not `$var`
- Always double-quote command substitutions: `"$(cmd)"` not `$(cmd)`
- Quote array expansions: `"${arr[@]}"` not `${arr[@]}`
- Single-quote static strings with special chars; double-quote when interpolation needed
- `"$@"` not `$@` in argument forwarding

### Conditionals

- `[[ ]]` over `[ ]` in zsh/bash — supports `&&`, `||`, `=~`, no word-splitting
- `(( ))` for arithmetic comparisons — not `[ $n -gt 0 ]`
- `-z`/`-n` for empty/non-empty string checks inside `[[ ]]`
- Avoid `[ "$a" == "$b" ]` — use `[[ "$a" == "$b" ]]`

### Functions

- `local` for all function-local variables — never pollute global scope
- Declare before use: `local var; var=$(cmd)` to catch errors (not `local var=$(cmd)`)
- Return status codes; callers check `$?` or use `if fn; then`

### Safety

- `set -euo pipefail` at top of scripts (exit on error, unset var, pipe failure)
- Not needed in interactive configs (`~/.zshrc`) — only scripts
- Check `cd` result: `cd /path || exit 1` or `cd /path || return 1`
- Avoid `eval` — if unavoidable, sanitize input; document why
- `rm` destructive operations: prefer `-i` flag or confirm before use

### Command Substitution & Subshells

- `$(command)` over backticks — nestable, readable
- Minimize subshells in loops; cache results in variables
- `$()` in assignments doesn't propagate exit codes — check separately

### Arrays

- `"${arr[@]}"` — each element as separate word (use in loops, argument lists)
- `"${arr[*]}"` — all elements as single word (use only for joining)
- `${#arr[@]}` for length
- zsh: arrays are 1-indexed; bash: 0-indexed — note in cross-compatible scripts

### Output

- `printf` over `echo` for portability — `echo` behavior varies across shells
- `echo` acceptable for simple newline-terminated strings in zsh-only scripts
- Write errors to stderr: `echo "error" >&2` or `printf "error\n" >&2`
- Use `\n` in `printf` not `echo -e`

### File & Path Handling

- Never parse `ls` output — use globs: `for f in *.txt; do`
- Never parse `find` output with `for` — use `find ... -print0 | xargs -0` or `while IFS= read -r -d ''`
- `IFS=` and `-r` flag in `while read` loops: `while IFS= read -r line`
- Use `[[ -f "$file" ]]` before reading; `[[ -d "$dir" ]]` before entering

### Heredocs

- `<<'EOF'` to prevent variable interpolation in static content
- `<<EOF` (unquoted) when interpolation is intentional
- Indent with `<<-EOF` (strips leading tabs, not spaces)

### zsh-specific

- `autoload -Uz func` to load functions lazily
- `zstyle` for configuration of completion and zle systems
- `compdef _func cmd` to assign completion function to command
- `_arguments` for structured completion specs
- `setopt` / `unsetopt` over `set -o` for zsh options
- `TRAPXXX` functions for signal handling

### Anti-patterns

- Unquoted `$var` · `ls | grep` / `ls | awk` · `cat file | cmd`
- `cd dir && do_thing` without error handling · `[[ ]]` with `-a`/`-o`
- Nested backticks · hardcoded `#!/bin/sh` with bash/zsh features
- `local var=$(cmd)` (masks exit code) · `source script` without existence check

## Output Format

Group by file. Use `file:line` format (VS Code clickable). Terse findings.

```text
## config/zsh/git.sh

config/zsh/git.sh:12 - unquoted $branch → "$branch"
config/zsh/git.sh:27 - [ ] → [[ ]]
config/zsh/git.sh:41 - local result=$(cmd) → local result; result=$(cmd)
config/zsh/git.sh:55 - cd without error check → cd /path || return 1

## config/zsh/aliases.zsh

✓ pass
```

State issue + location. Skip explanation unless fix non-obvious. No preamble.
