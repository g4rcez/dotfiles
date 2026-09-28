#!/bin/bash

if [ "$(tmux -S "$TMUX_SOCKET_PATH" display-message -p -F "#{session_name}")" = "popup" ]; then
    tmux -S "$TMUX_SOCKET_PATH" detach-client
else
    tmux -S "$TMUX_SOCKET_PATH" popup -h 70% -w 70% -E "tmux -S \"\$TMUX_SOCKET_PATH\" attach -t popup || tmux -S \"\$TMUX_SOCKET_PATH\" new -s popup" &
    tmux -S "$TMUX_SOCKET_PATH" source "$HOME/dotfiles/config/tmux/tmux.conf"
fi
