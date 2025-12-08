#!/bin/bash
source "$HOME/dotfiles/zsh/utils.sh";
# SCRIPTS_PATH="$HOME/dotfiles/bin"

tmux_get() {
    local value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# short for Theme-Colour
TC="#89b4fa"
FG="#89b4fa"
DISABLED="#64748b"
HIGHLIGHT="#89b4fa"
G04=#141621
BG="#1A1B26"

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_fg "$HIGHLIGHT"
tmux_set @prefix_highlight_bg "$TC"
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG"
tmux_set @prefix_highlight_output_prefix "#[fg=$HIGHLIGHT]#[bg=$BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$HIGHLIGHT]#[bg=$BG]"

# Left side of status bar
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$FG"
tmux_set status-left-length 150
tmux_set status-left " #{prefix_highlight} "
# tmux_set status-left "#[fg=$FG,bg=$BG] $session_icon #S #{prefix_highlight} "

# Right side of status bar
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$FG"
tmux_set status-right-length 200
# tmux_set status-right "  #(basename \"#{pane_current_path}\")"
tmux_set status-right " #S "

# Window status format
tmux_set window-status-format "#[fg=$DISABLED,bg=$BG] #I:#W "
tmux_set window-status-current-format "#[fg=$HIGHLIGHT,bg=$BG] #I:#W "

# Window status style
tmux_set window-status-style "fg=$FG,bg=$BG,none"
tmux_set window-status-last-style "fg=$TC,bg=$BG"
tmux_set window-status-activity-style "fg=$TC,bg=$BG"

# Window separator
tmux_set window-status-separator "#[fg=$DISABLED,bg=$BG]⋮"

# Pane border
tmux_set pane-border-style "fg=default,bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=$BG"

# Pane number indicator
tmux_set display-panes-colour "$BG"
tmux_set display-panes-active-colour "$TC"

# Message
tmux_set message-style "fg=$TC,bg=$BG"

# Command message
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=#000000"
