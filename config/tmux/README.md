# tmux

Claude Code inside tmux gets two fixes here:

- passthrough + extended keys so notifications and Shift+Enter survive tmux
- `CLAUDE_CODE_TMUX_TRUECOLOR=1` so Claude keeps truecolor rendering in tmux

Reload the server after edits:

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

Rollback: remove the Claude-specific lines from `tmux.conf` and source it again.
