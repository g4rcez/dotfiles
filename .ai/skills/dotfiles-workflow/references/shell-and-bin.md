# Shell, `bin/` scripts, OS control, HTTP, CLI languages

Read the shebang of every file before editing. `bin/` mixes bash and zsh. `config/zsh/alias.sh` is zsh despite its shebang. For language rules, load the `shell-bash` or `shell-zsh` skill. `AGENTS.md` holds the repo rules (cwd wrappers, heredoc quoting, no startup subprocesses, completion registration).

## Where things live

- `bin/`: standalone commands. Shared helpers in `bin/lib/dotfiles-shell.sh` (most scripts source it first, then `config/zsh/fzf.sh` when they use fzf).
- `config/zsh/`: `zshrc` is the entrypoint. `alias.sh`, `git.sh`, `fzf.sh`, `exports.sh`, `utils.sh`, `completion/`.
- `bin/dots` runs the Bun-based `bunsen` CLI that deploys symlinks (`dotfiles.config.ts`). A new `config/<tool>/` needs an entry there.
- OS setup: `bin/setup-osx`, `bin/manjaro.sh`. Window management: `config/aerospace`. Key remapping: Karabiner (see the boundary note in `AGENTS.md`).
- Other CLI languages in use: Bun/TypeScript (`bunsen`, `tests/bun`, `bin/dots`), and Rust/Go tools installed through mise. Match the language already used by the nearest tool. A shell script is the default for glue. Switch language only when the script needs real parsing, concurrency, or a long-lived process.

## Before writing a new script

1. Search `bin/` for a tool with the same job (`ls bin`, grep for the verb). Candidates: `workstate`, `task-checkpoint`, `repo-check`, `notes`, `filepicker`, `json-inspect`, `gh-fzf`.
2. Decide the cwd question first (wrapper in `alias.sh` or not).
3. Add `-h/--help` text in the style of `repo-check` (a quoted heredoc usage block).
4. If it uses fzf: source `config/zsh/fzf.sh` and reuse the layout from `bin/rex-fzf-session`.
5. If it registers a completion, add the file to the `SOURCE` array in `config/zsh/zshrc` and grep it at the end (hard rule in `AGENTS.md`).

## HTTP with curl and jq

- Use `curl -fsS` (fail on HTTP errors, hide the progress bar, keep errors). Add `--max-time` for anything in a loop or a hook.
- Build JSON with `jq -n --arg k "$v" '{k:$k}'`. Never interpolate values into a JSON string by hand.
- Parse with `jq -r` and `// empty` for optional fields. Check the real response shape before writing the filter. Do not guess field names.
- Pass tokens through the environment or a file. Never print them, log them, or put them in a URL. Send them with `-H @file` or an env-expanded header.
- ANSI escapes in jq: pass `--arg esc $'\033'`. Never put the raw ESC byte in the filter.
- For a repeatable API flow, a `.http` file under the Kulala setup (`config/nvim/lua/plugins/kulalahttp.lua`) can be better than a script. Mention it as an option when the user wants to explore an API interactively.

## OS control

- macOS: `defaults`, `osascript`, `launchctl`, `open`, `pbcopy/pbpaste`, Aerospace CLI. Linux (Manjaro): `systemctl`, `xdg-open`, the distro package manager. Gate OS-specific code with `[[ $OSTYPE == darwin* ]]`. Do not call `uname` at shell startup.
- Prefer the CLI of the tool (`aerospace`, `rex`) over GUI scripting. Do not use GUI automation unless there is no CLI.
- Network checks: `curl -fsS --max-time`, `dig`, `nc -z`, `lsof -nP -iTCP -sTCP:LISTEN`. Read-only by default. Ask before anything that changes network or firewall state.

## Verify

`bash tests/shell/syntax-test.bash` for any shell change. Add the area test from `references/verify.md`. For a script with logic, write a `tests/shell/<name>-test.bash` using `test-helper.bash`.
