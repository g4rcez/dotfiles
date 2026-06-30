#!/usr/bin/env bash

# Applies the visual theme for tmux's status bar and pane/message styles.
source "$HOME/dotfiles/zsh/utils.sh"

# Read a tmux option with a fallback. Kept for quick theme tweaks.
# Quiet global option setter used below to keep the theme lines compact.
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Theme colors.
TC="#89b4fa"        # primary accent
FG="#89b4fa"        # default foreground
DISABLED="#64748b"  # inactive window text/separators
HIGHLIGHT="#89b4fa" # active/prefix highlight
G04=#141621          # darker status-left background
BG="#1A1B26"        # main status background

# Refresh the status bar every second so dynamic segments stay current.
tmux_set status-interval 1
tmux_set status on

# Base status bar colors.
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none

# tmux-prefix-highlight: shows whether prefix/copy-mode is active.
tmux_set @prefix_highlight_fg "$HIGHLIGHT"
tmux_set @prefix_highlight_bg "$TC"
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG"
tmux_set @prefix_highlight_output_prefix "#[fg=$HIGHLIGHT]#[bg=$BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$HIGHLIGHT]#[bg=$BG]"

# Left status segment: git branch for the active pane, then prefix/copy-mode indicator.
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$FG"
tmux_set status-left-length 150
tmux_set status-left " #{prefix_highlight} #(bash $HOME/dotfiles/bin/git-branch.sh #{q:pane_current_path} icon 2>/dev/null) #[fg=$FG,bg=$BG]"

# Right status segment: current session name. Other useful segments are left as examples.
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$FG"
tmux_set status-right-length 200
# Dir: tmux_set status-right "  #(basename \"#{pane_current_path}\")"
# AI: tmux_set status-right "#($DOTFILES/.ai/statusline.sh --compact) #[fg=$FG,bg=$BG] #S "
tmux_set status-right " #S "

# Inactive and active window labels in the center of the status bar.
tmux_set window-status-format "#[fg=$DISABLED,bg=$BG] #I:#W "
tmux_set window-status-current-format "#[fg=$HIGHLIGHT,bg=$BG] #I:#W "

# Window label styling for normal, last-used, and activity states.
tmux_set window-status-style "fg=$FG,bg=$BG,none"
tmux_set window-status-last-style "fg=$TC,bg=$BG"
tmux_set window-status-activity-style "fg=$TC,bg=$BG"

# Separator between window labels.
tmux_set window-status-separator "#[fg=$DISABLED,bg=$BG]⋮"

# Pane borders; only the active pane gets the accent color.
tmux_set pane-border-style "fg=default,bg=default"
tmux_set pane-active-border-style "fg=$TC,bg=$BG"

# Colors for the temporary pane-number overlay shown by prefix + q.
tmux_set display-panes-colour "$BG"
tmux_set display-panes-active-colour "$TC"

# Command/status message colors.
tmux_set message-style "fg=$TC,bg=$BG"
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy-mode selection/search highlight.
tmux_set mode-style "bg=$TC,fg=#000000"
