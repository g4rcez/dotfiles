SCRIPTS_PATH="$HOME/dotfiles/bin"
tmux_get() {
    local value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Options
rarrow=$(tmux_get '@tmux_power_right_arrow_icon' '█')
larrow=$(tmux_get '@tmux_power_left_arrow_icon' '█')
upload_speed_icon=$(tmux_get '@tmux_power_upload_speed_icon' '󰕒')
download_speed_icon=$(tmux_get '@tmux_power_download_speed_icon' '󰇚')
session_icon="$(tmux_get '@tmux_power_session_icon' '')"
user_icon="$(tmux_get '@tmux_power_user_icon' '')"
prefix_highlight_pos=$(tmux_get @tmux_power_prefix_highlight_pos)
# short for Theme-Colour
TC=$(tmux_get '@tmux_power_theme' '##669EF9')
G01=#080808 #232
G02=#121212 #233
G03=#1c1c1c #234
G04=#141621 #235
G05=#303030 #236
G06=#1e293b #237
G07=#27272a #238
G08=#4e4e4e #239
G09=#585858 #240
G10=#626262 #241
G11=#6c6c6c #242
G12=#767676 #243

FG="$G10"
BG="$G04"

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_fg "$BG"
tmux_set @prefix_highlight_bg "$FG"
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$BG]$larrow#[bg=$TC]#[fg=$BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$BG]$rarrow"

# Left side of status bar
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$G12"
tmux_set status-left-length 150
LS="#[fg=$TC,bg=$G06] $session_icon #S "
# if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
#    LS="$LS#{prefix_highlight}"
# fi
tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$G12"
tmux_set status-right-length 150
git_status="#(bash $SCRIPTS_PATH/git-branch.sh \"#{pane_current_path}\")"
RS="#[fg=$G06]$larrow#[fg=$TC,bg=$G06]  #(basename \"#{pane_current_path}\") #[fg=$TC,bg=$G06]"
RS="#[fg=$G07]$larrow#[fg=$TC,bg=$G07]  $git_status $RS"
if "$show_web_reachable"; then
    RS=" #{web_reachable_status} $RS"
fi
if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi
tmux_set status-right "$RS"

# Window status format
tmux_set window-status-format "#[fg=$BG,bg=$G06]$rarrow#[fg=$TC,bg=$G06] #I:#W #[fg=$G06,bg=$BG]$rarrow"
tmux_set window-status-current-format "#[fg=$BG,bg=$TC]$rarrow#[fg=$BG,bg=$TC,bold] #I:#W #[fg=$TC,bg=$BG,nobold]$rarrow"

# Window status style
tmux_set window-status-style "fg=$TC,bg=$BG,none"
tmux_set window-status-last-style "fg=$TC,bg=$BG,bold"
tmux_set window-status-activity-style "fg=$TC,bg=$BG,bold"

# Window separator
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=$G07,bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$G07"
tmux_set display-panes-active-colour "$TC"

# Message
tmux_set message-style "fg=$TC,bg=$BG"

# Command message
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$FG"
