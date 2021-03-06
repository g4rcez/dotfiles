time_since_last_commit() {
  if last_commit=$(git log --pretty=format:'%at' -1 2>/dev/null); then
    now=$(date +%s)
    seconds_since_last_commit=$((now - last_commit))
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit / 3600))
    days=$((seconds_since_last_commit / 86400))
    sub_hours=$((hours % 24))
    sub_minutes=$((minutes % 60))
    if [ $hours -gt 24 ]; then
      commit_age="${days}d"
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h${sub_minutes}m"
    else
      commit_age="${minutes}m"
    fi
    color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
    echo "%{$reset_color%} ${color}LastCommit: $commit_age%{$reset_color%}"
  fi
}

check_git() {
  local URL="$(git config --get remote.origin.url)"
  if [[ "$(echo $URL | grep 'github')" != "" ]]; then
    echo -n " \uf09b %{$fg_bold[white]%}%{$resetcolor%} "
  elif [[ "$(echo $URL | grep 'gitlab')" != "" ]]; then
    echo -n " \uf296 %{$fg_bold[white]%}%{$resetcolor%} "
  elif [[ "$(echo $URL | grep 'bitbucket')" != "" ]]; then
    echo -n " \uf171 %{$fg_bold[white]%}%{$resetcolor%} "
  fi
}

exitstatus() {
  if [[ $? != 0 ]]; then
    echo -n "%{$fg_bold[red]%} %{$reset_color%}"
  fi
}

ZSH_THEME_GIT_PROMPT_PREFIX=""

fishify() {
  echo $(pwd | perl -pe '
   BEGIN {
      binmode STDIN,  ":encoding(UTF-8)";
      binmode STDOUT, ":encoding(UTF-8)";
   }; s|^$ENV{HOME}|~|g; s|/([^/.])[^/]*(?=/)|/$1|g; s|/\.([^/])[^/]*(?=/)|/.$1|g
')
}

current_env() {
  if [[ -e "./package.json" ]]; then
    echo -n "%{$fg_bold[green]%}\uf898%{$reset_color%} "
  fi
  if [[ -e "./pom.xml" ]]; then
    echo -n "%{$fg_bold[yellow]%}\ue738%{$reset_color%} "
  fi
  if [[ -e "./Program.cs" ]]; then
    echo -n "%{$fg_bold[cyan]%}\ue77f%{$reset_color%} "
  fi
  if [[ -e "./tsconfig.json" ]]; then
    echo -n "%{$fg_bold[blue]%}\ue628%{$reset_color%} "
  fi
}

dir_name() {
  local URL="$(git config --get remote.origin.url)"
  if [[ "$URL" =~ ^git@.* ]]; then
    D2=$(dirname "$PWD")
    PATH_SHOW=$(basename "$D2")/$(basename "$PWD")
    echo "$(git config --get remote.origin.url | cut -d ':' -f2) [$PATH_SHOW]"
    return
  fi
  fishify
}

PROMPT='
%{$resetcolor%}$(exitstatus)%{$fg_bold[cyan]$(dir_name)%}%{$reset_color%} $(check_git)$(git_prompt_info)%{$fg_bold[green]$(time_since_last_commit)%}%{$reset_color%}
%{$fg_bold[$CARETCOLOR]%}%{$resetcolor%} '

RPROMPT='%{$resetcolor%}%{$(echotc UP 1)%}$(current_env)$(date "+%Y-%m-%d %H:%M") %{$(echotc DO 1)%}%{$resetcolor%}'

if [[ $USER == "root" ]]; then
  CARETCOLOR="red"
else
  CARETCOLOR="white"
fi

ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$reset_color%}"
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

########## CLI Utils ##########

setopt append_history
setopt auto_pushd
setopt autocd
setopt extended_glob
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt pushd_ignore_dups
setopt pushd_minus
setopt share_history
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS+=("rm -rf " "fg=red,bold")
ZSH_HIGHLIGHT_PATTERNS+=("mv" "fg=yellow,bold")
ZSH_HIGHLIGHT_STYLES[alias]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=blue,bold"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=magenta,bold"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=yellow"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=yellow,bold"
ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=cyan"
ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=yellow"
ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=magenta"
ZSH_HIGHLIGHT_STYLES[bracket-level-4]="fg=blue"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=009
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=009
ZSH_HIGHLIGHT_STYLES[path]="fg=blue,underline"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=blue,underline"
ZSH_HIGHLIGHT_STYLES[globbing]=fg=063
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=009

bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
