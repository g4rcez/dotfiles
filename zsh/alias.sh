#!/bin/bash

######################### *nix alias #########################
alias cp='cp -v'
alias df='df -h'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias ls="exa --icons --color=always -bghHiS"
alias more='less'
alias mv='mv -v'
alias rm='rm -v'
alias vdir='vdir --color=auto'
alias wtf='pwd'
# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
################################### OSX ##########################################
if [[ "$(uname -o)" == "Darwin" ]]; then
  # macOS has no `md5sum`, so use `md5` as a fallback
  command -v md5sum >/dev/null || alias md5sum="md5"

  # macOS has no `sha1sum`, so use `shasum` as a fallback
  command -v sha1sum >/dev/null || alias sha1sum="shasum"
  command -v hd > /dev/null || alias hd="hexdump -C"
  alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"
  source "$HOME/.iterm2_shell_integration.zsh"
fi
########################## CLIPBOARD ##########################################
if [[ "$(uname -o)" != "Darwin" ]]; then
  alias pbcopy='xclip -sel clip'
  alias pbpaste='xclip -selection clipboard -o'
fi
######################### Git/Github CLI utils #########################
alias add='git add'
alias commit='git commit -m'
alias gitree="git log --oneline --graph --decorate --all"
alias push='git push -u'
alias pull='git pull'
alias tags='git tag | sort -V'
alias rebase='git rebase'
alias checkout='git checkout'
alias ghc="gh pr checkout"
alias ghl="gh pr list"
alias wip="git add . && git commit -m 'wip: work in progress' && git push"
alias gittree=git-graph
alias gitree=git-graph
######################### General stuff #########################
alias n="pnpm"
alias vim="lvim"
alias cat="bat -p --pager cat --theme OneHalfDark"
alias ll="ls -l"
alias files="fzf --multi --preview 'bat --style=numbers --color=always --line-range :500 {}'"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

######################################### Node ########################################
# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=~/.node_history;
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768';
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy';


function docker-prune-volumes () {
  docker volume rm $(docker volume ls -q --filter dangling=true)
}
function dockerkill () {
  docker kill $(docker ps -q)
}

if [ -x "$(command -v lvim)" ]; then
  alias vim="lvim"
fi

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
export FZF_DEFAULT_OPTS=' --height 40% --layout=reverse --border --info=inline --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
source "$HOME/dotfiles/scripts/fzf-git"
##################################### Functions #####################################
function memory() {
  ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f MB ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
}

function clone() {
  git clone "git@github.com:$1"
}

function tag() {
  git tag "$1" && git push origin "$1"
}

function cdm() {
  mkdir -p "$1"
  cd "$1"
}

function node:scripts() {
  cat "$PWD/package.json" | jq .scripts
}

function cpv() {
  rsync -pogbr -hhh --backup-dir="$HOME/.tmp" -e /dev/null --progress "$@"
}

function git-graph() {
  git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
}


function extract() {
  if [ -f "$FILE" ]; then
    case $FILE in
    *.tar.bz2) tar xjf "$FILE" ;;
    *.tar.gz) tar xzf "$FILE" ;;
    *.bz2) bunzip2 "$FILE" ;;
    *.rar) unrar x "$FILE" ;;
    *.gz) gunzip "$FILE" ;;
    *.tar) tar xf "$FILE" ;;
    *.tbz2) tar xjf "$FILE" ;;
    *.tgz) tar xzf "$FILE" ;;
    *.zip) unzip "$FILE" ;;
    *.Z) uncompress "$FILE" ;;
    *.7z) 7z x "$FILE" ;;
    *) echo "'$FILE' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$FILE' is not a valid file"
  fi
}

# dotnet autocomplete
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi

  # This is not a variable assignment, don't remove spaces!
  _values = "${(ps:\n:)completions}"
}

function listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

alias listen=listening

function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null >/dev/null 2>&1; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@"
	else
		du $arg .[^.]* ./*
	fi
}

