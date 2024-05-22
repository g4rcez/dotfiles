#!/bin/bash

if [ "$(tmux display-message -p -F "#{session_name}")" = "popup" ]; then
    tmux detach-client
else
    tmux popup -h 70% -w 70% -E "tmux attach -t popup || tmux new -s popup" &
    tmux source "$HOME/dotfiles/config/tmux/tmux.conf"
fi
