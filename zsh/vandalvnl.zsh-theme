#!/bin/zsh
color_prompt=yes
force_color_prompt=yes
zmodload zsh/complist
autoload -U compinit; compinit
_comp_options+=(globdots)

setopt aliases
setopt append_history
setopt auto_list            # Automatically list choices on ambiguous completion.
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
setopt menu_complete        # Automatically highlight first element of completion menu
setopt notify
setopt promptsubst
setopt pushd_ignore_dups
setopt rmstarsilent
setopt share_history
setopt transient_rprompt

export LESSOPEN='|~/dotfiles/bin/lessfilter.sh %s'
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
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:brew-(install|uninstall|search|info):*-argument-rest' fzf-preview 'brew info $word'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}?%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}\uf62b%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[magenta]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

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

bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^Xa' alias-expension

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
