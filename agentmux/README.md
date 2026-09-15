# agentmux

A tmux-native dashboard for coding agents. It has one shared agent registry and two views:

- `agentmux dashboard` opens the full dashboard.
- `agentmux sidebar` opens the compact view used by the right tmux pane.
- `agentmux snapshot` prints detected agents without opening a TUI.
- `gh.runs` monitors the latest 20 GitHub Actions runs.
  Use `gh.runs --repo OWNER/REPO` to select a repository; without it, the CWD repository is used.

Pi reports lifecycle state through `config/pi/extensions/agentmux-status.ts`: agent runs are working, blocking UI prompts are waiting, and settled runs are done. The extension is a no-op outside tmux and removes its pane record when Pi shuts down. Other supported agents are discovered from processes and show an unknown state until their lifecycle integrations are added.

State is stored in `AGENTMUX_STATE_DIR`, `$XDG_RUNTIME_DIR/agentmux`, or the current user's temporary directory, in that order. State directories and files use private permissions.

## Keys

- `j`/`k` or arrows: select an agent
- `Enter` or `l`: jump to its tmux pane
- `g`/`G`: first or last agent
- `f`: show all sessions or only the current session
- `q` or `Esc`: close

## `gh.runs`

```sh
gh.runs [--repo OWNER/REPO]
```

## `gh.runs` keys

- `j`/`k` or arrows: select a run
- `Enter`: open the selected run in the browser (latest run is selected first)
- `r`: refresh now
- `q` or `Esc`: close
