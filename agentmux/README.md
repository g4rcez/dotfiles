# agentmux

A tmux-native dashboard for coding agents. It has one shared agent registry and two views:

- `agentmux dashboard` opens the full dashboard.
- `agentmux sidebar` opens the compact view used by the right tmux pane.
- `agentmux snapshot` prints detected agents without opening a TUI.

Pi reports lifecycle state through `config/pi/extensions/agentmux-status.ts`. Other supported agents are discovered from processes and show an unknown state until their lifecycle integrations are added.

State is stored in `AGENTMUX_STATE_DIR`, `$XDG_RUNTIME_DIR/agentmux`, or the current user's temporary directory, in that order.

## Keys

- `j`/`k` or arrows: select an agent
- `Enter` or `l`: jump to its tmux pane
- `g`/`G`: first or last agent
- `f`: show all sessions or only the current session
- `q` or `Esc`: close
