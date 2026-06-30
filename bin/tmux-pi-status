#!/usr/bin/env bash
# Reads pi status for the active tmux pane. Returns empty if no pi running.
PANE_ID=$(tmux display-message -p '#{pane_id}' 2>/dev/null | tr -d '%')
[ -z "$PANE_ID" ] && exit 0
STATUS_FILE="/tmp/pi-tmux-status-${PANE_ID}"
[ -f "$STATUS_FILE" ] && cat "$STATUS_FILE"
