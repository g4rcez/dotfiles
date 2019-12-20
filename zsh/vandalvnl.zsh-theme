# # vim:ft=zsh ts=2 sw=2 sts=2
_git_time_since_commit() {
  if last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null); then
    now=$(date +%s)
    seconds_since_last_commit=$((now-last_commit))
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit/3600))
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

gitverify(){
    local URL="$(git config --get remote.origin.url)"
    if [[ "$(echo $URL| grep 'github')" != "" ]]; then
        echo -n " \uf09b %{$fg_bold[white]%}%{$resetcolor%} "
    elif [[ "$(echo $URL| grep 'gitlab')" != "" ]]; then
        echo -n " \uf296 %{$fg_bold[white]%}%{$resetcolor%} "
    elif [[ "$(echo $URL| grep 'bitbucket')" != "" ]]; then
        echo -n " \uf171 %{$fg_bold[white]%}%{$resetcolor%} "
    fi
}

exitstatus() {
    if [[ $? == 0 ]]; then
        echo -n "%{$fg_bold[green]%}+%{$reset_color%}"
    else
        echo -n "%{$fg_bold[red]%}x%{$reset_color%}"
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
        echo -n "%{$fg_bold[green]%}\uf898 $(node --version|tr -d '\n \t\ra-z')%{$reset_color%} "
    fi
    if [[ -e "./pom.xml" ]]; then
        echo -n "%{$fg_bold[yellow]%}\ue738 $(javac -version 2>&1 | head -1 | tr -d '\n\t\r '|sed 's/[^0-9.]//g')%{$reset_color%} "
    fi
    if [[ -e "./Program.cs" ]]; then
        echo -n "%{$fg_bold[cyan]%}\ue77f $(dotnet --version)%{$reset_color%} "
    fi
    if [[ -e "./tsconfig.json" ]]; then
        echo -n "%{$fg_bold[blue]%}\ue628 $(tsc --version|cut -d ' ' -f2)%{$reset_color%} "
    fi
}

PROMPT='
%{$resetcolor%}$(exitstatus) %{$fg_bold[green]%n@%m%}%{$reset_color%} %{$fg_bold[blue][$(fishify)]%}%{$reset_color%} $(gitverify)$(git_prompt_info)%{$fg_bold[green]$(_git_time_since_commit)%}%{$reset_color%}
%{$fg_bold[$CARETCOLOR]%}%{$resetcolor%} '

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
