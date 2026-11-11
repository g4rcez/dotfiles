# Rex and AI session visibility

Rex is the active terminal and multiplexer. The live view of AI sessions already exists. Extend it; do not rebuild it.

## What exists

| Piece | File | What it does |
|---|---|---|
| Session list and switch | `bin/ai sessions` | fzf list of panes that run an AI CLI. `ctrl-d` kills, `ctrl-x` sends `/clear`, `ctrl-r` reloads. |
| Live monitor | `bin/ai monitor` | Same list with auto-refresh and a pane preview. Refresh loop talks to fzf `--listen` through curl. |
| Statusline | `bin/ai --_statusline` | Prints running/idle/done counts. Does not need `jq`. |
| Mux detection | `_ai_mux` in `bin/ai` | `AI_MUX` override, then `$TMUX`, then `$REX_SESSION`, then a reachable tmux server, then Rex. |
| Cockpit tab | `config/rex/extensions/cockpit.lua`, `bin/rex-cockpit-sidebar`, `bin/rex-cockpit-panel` | Fixed left sidebar of sessions with status, a main terminal, and a right git panel. Currently untracked work in progress. |
| Rex fzf pickers | `bin/rex-fzf-session`, `bin/rex-fzf-windows`, `bin/rex-fzf-agents`, `bin/rex-fzf-preview` | Reuse their fzf styling and layout. |
| Rex extensions | `config/rex/extensions/*.lua` | One extension per behavior (`agents.lua`, `watcher.lua`, `cockpit.lua`, ...). Types are in `config/rex/types/`. |

## How agent state is read in Rex

- Agent state comes from the Program Status Protocol: `rex block call -s <session> -b <block> program_status`. The result has `.records[].state` (`working`, `done`, `failed`, and so on) and an optional `.msg`.
- `bin/ai` maps `working` to running, `done`/`failed` to done, anything else to idle.
- Which pane runs an agent: `rex block call ... process` returns the foreground process. `_ai_agent_name` checks the basename of argv[0] and argv[1] (Node-based CLIs show as `node`).
- Pane ids travel as `SESSION,BLOCK,WINDOW` inside `bin/ai`. Rex ids contain no commas.
- To switch the app view: `rex focus -s <session> <block>` plus `rex -C <client> do session.select session_id=... window_id=...`.

## Rules for changes here

- Read `rex skill show` (or the `rex` skill) before writing any `rex` command. Pass `-s "$REX_SESSION"` and `-b "$REX_BLOCK"` when targeting the current pane.
- The Rex Lua sandbox has no `utf8` library. Pane cwd arrives as an OSC 7 `file://` URL: strip and percent-decode it (`config/rex/extensions/cwd.lua` already does this; reuse it).
- A Rex block cannot move between sessions, so a "shared sidebar" is a per-session copy (see the header of `cockpit.lua`).
- fzf reload commands run through `$SHELL` (zsh), which drops exported bash functions. Re-run the script with a `--rows` flag, as `rex-cockpit-sidebar` does.
- Every `bin/` script that calls `fzf` must source `config/zsh/fzf.sh`.
- Keep tmux behavior working in `bin/ai` only because it is still there. Do not extend tmux paths for new features unless asked.

## Live view: known gaps (feed these into Workflow findings when relevant)

- The statusline counts states but does not say which session needs the user. A "waiting for me" state is the highest-value signal.
- The sidebar shows only the first block's status per session. A session with several agents shows one.
- No history view: what each session changed or decided. `ai-memory` and the transcript JSONL files hold that data. Transcript format is in `AGENTS.md` (Claude Code Hooks section).
- No notification when a session moves from working to done. `bin/claude-notify` exists; check how it is wired before adding another path.

## Verify

`bash tests/shell/ai-statusline-test.bash`, `bash tests/shell/fzf-layout-test.bash`, `bash tests/shell/syntax-test.bash`. For Lua: the loadfile syntax check in `references/verify.md`, then tell the user which action to try in Rex.
