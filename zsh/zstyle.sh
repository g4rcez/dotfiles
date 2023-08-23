#!/bin/zsh
WORDCHARS=''
#zmodload -i zsh/complist
unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
# use brace
setopt brace_ccl
# Max number of entries to keep in history file.
SAVEHIST=$(( 100 * 1000 ))      # Use multiplication for readability.
# Max number of history entries to keep in memory.
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value
# Use modern file-locking mechanisms, for better safety & performance.
setopt HIST_FCNTL_LOCK
# Keep only the most recent copy of each duplicate entry in history.
setopt HIST_IGNORE_ALL_DUPS
# Auto-sync history between concurrent sessions.
setopt SHARE_HISTORY
setopt aliases
setopt always_to_end
setopt append_history
setopt auto_list
setopt auto_menu         # show completion menu on successive tab press
setopt auto_pushd
setopt autocd
setopt automenu
setopt autopushd pushdminus pushdsilent pushdtohome pushdignoredups
setopt complete_in_word
setopt correctall
setopt extended_glob
setopt extended_history
setopt glob_complete      # Show autocompletion menu with globs
setopt globdots
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt histignorealldups
setopt histreduceblanks
setopt magicequalsubst
setopt notify
setopt promptsubst
setopt pushd_ignore_dups
setopt rmstarsilent
setopt share_history
# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
bindkey -M menuselect '^[[Z' reverse-menu-complete
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# ... unless we really want to.
zstyle '*' single-ignored show

if [[ ${COMPLETION_WAITING_DOTS:-false} != false ]]; then
  expand-or-complete-with-dots() {
    # use $COMPLETION_WAITING_DOTS either as toggle or as the sequence to show
    [[ $COMPLETION_WAITING_DOTS = true ]] && COMPLETION_WAITING_DOTS="%F{red}…%f"
    # turn off line wrapping and print prompt-expanded "dot" sequence
    printf '\e[?7l%s\e[?7h' "${(%)COMPLETION_WAITING_DOTS}"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  # Set the function as the default tab completion widget
  bindkey -M emacs "^I" expand-or-complete-with-dots
  bindkey -M viins "^I" expand-or-complete-with-dots
  bindkey -M vicmd "^I" expand-or-complete-with-dots
fi

color_prompt=yes
force_color_prompt=yes
_comp_options+=(globdots)

zstyle ':completion:*' complete true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:alias-expension:*' completer _expand_alias
zstyle ':completion:complete:*:options' sort false
############################## zsh-notify ##############################################
zstyle ':notify:*' always-notify-on-failure no
zstyle ':notify:*' command-complete-timeout 10
zstyle ':notify:*' error-title "Command failed (in #{time_elapsed} seconds)"
zstyle ':notify:*' error-title "Command failed"
zstyle ':notify:*' success-title "Command finished (in #{time_elapsed} seconds)"
zstyle ':notify:*' success-title "Command finished"
zstyle ':notify:*' enable-on-ssh yes
##################################### znap ###########################################
zstyle ':znap:*:*' git-maintenance off
############################## key Bind #################################
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^Xa' alias-expension

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS+=("rm -rf " "fg=red,bold")
ZSH_HIGHLIGHT_PATTERNS+=("mv " "fg=yellow,bold")
ZSH_HIGHLIGHT_STYLES[alias]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=yellow"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=green"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=yellow"
ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=white"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[globbing]=fg=063
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=yellow,underline"
ZSH_HIGHLIGHT_STYLES[path]="fg=yellow,underline"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=009

#ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}?%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}\uf62b%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
#ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
#ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
#ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
#ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
#ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "
#

## Colors vary depending on time lapsed.
#ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[magenta]%}"
#ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
#ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
#ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

# time_since_last_commit() {
#   if last_commit=$(git log --pretty=format:'%at' -1 2>/dev/null); then
#     now=$(date +%s)
#     seconds_since_last_commit=$((now - last_commit))
#     minutes=$((seconds_since_last_commit / 60))
#     hours=$((seconds_since_last_commit / 3600))
#     days=$((seconds_since_last_commit / 86400))
#     sub_hours=$((hours % 24))
#     sub_minutes=$((minutes % 60))
#     if [ $hours -gt 24 ]; then
#       commit_age="${days}d"
#     elif [ $minutes -gt 60 ]; then
#       commit_age="${sub_hours}h${sub_minutes}m"
#     else
#       commit_age="${minutes}m"
#     fi
#     color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
#     echo "%{$reset_color%} ${color}LastCommit: $commit_age%{$reset_color%}"
#   fi
# }

# local URL="$(git config --get remote.origin.url)"

# check_git() {
#   if [[ URL == "" ]]; then
#     echo -n ""
#   elif if [[ "$(echo $URL | grep 'github')" != "" ]]; then
#     echo -n " \uea84%{$fg_bold[white]%}%{$resetcolor%} "
#   elif [[ "$(echo $URL | grep 'gitlab')" != "" ]]; then
#     echo -n " \uf296%{$fg_bold[white]%}%{$resetcolor%} "
#   elif [[ "$(echo $URL | grep 'bitbucket')" != "" ]]; then
#     echo -n " \uf171%{$fg_bold[white]%}%{$resetcolor%} "
#   fi
# }

# function exitstatus() {
#   if [[ $? != 0 ]]; then
#     echo -n "%{$fg_bold[red]%}✗%{$reset_color%}"
#   fi
# }

# ZSH_THEME_GIT_PROMPT_PREFIX=""

# function fishify() {
#   echo $(echo "$1" | perl -pe '
#    BEGIN {
#       binmode STDIN,  ":encoding(UTF-8)";
#       binmode STDOUT, ":encoding(UTF-8)";
#    }; s|^$ENV{HOME}|~|g; s|/([^/.])[^/]*(?=/)|/$1|g; s|/\.([^/])[^/]*(?=/)|/.$1|g
# ')
# }

# function current_env() {
#   if [[ -e "./package.json" ]]; then
#     export PATH="$PATH:./node_modules/.bin"
#     echo -n "%{$fg_bold[green]%}\uf898%{$reset_color%} "
#   fi
#   if [[ -e "./Program.cs" ]]; then
#     echo -n "%{$fg_bold[cyan]%}\ue77f%{$reset_color%} "
#   fi
#   if [[ -e "./tsconfig.json" ]]; then
#     echo -n "%{$fg_bold[cyan]%}\ufbe4%{$reset_color%} "
#   fi
# }

# function dir_name() {
#   local PATH_SHOW="$(fishify $(pwd))"
#   if [[ "$URL" =~ ^git@.* ]]; then
#     echo "[$PATH_SHOW] $(git config --get remote.origin.url | cut -d ':' -f2 | sed 's/.git$//g')"
#     return
#   fi
#   echo "$PATH_SHOW"
# }

# PROMPT='
# %{$resetcolor%}$(exitstatus)%{$fg_bold[blue]$(dir_name)%}%{$reset_color%}$(check_git)$(git_prompt_info)%{$fg_bold[green]$(time_since_last_commit)%}%{$reset_color%}
# %{$fg_bold[$CARETCOLOR]%}>%{$resetcolor%} '

# RPROMPT='%{$resetcolor%}%{$(echotc UP 1)%}$(current_env)$(date "+%Y-%m-%d %H:%M")%{$(echotc DO 1)%}%{$resetcolor%}'

# if [[ $USER == "root" ]]; then
#   CARETCOLOR="red"
# else
#   CARETCOLOR="white"
# fi
