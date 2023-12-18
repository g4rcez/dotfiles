#!/bin/bash
####################################################### *nix alias #####################################################
alias cp='cp -v'
alias df='df -h'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias ls="eza --hyperlink --icons --git --color=always -bghHiS"
alias more='less'
alias mv='mv -v'
alias rm='rm -v'
alias vdir='vdir --color=auto'
alias wtf='pwd'
alias ll="ls -l"
alias cat="bat -p --pager cat --theme OneHalfDark"
alias dotfiles="cd $HOME/dotfiles"
# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

function memory() {
  ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f MB ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
}

function cdm() {
  mkdir -p "$1"
  cd "$1"
}

function cpv() {
  rsync -pogbr -hhh --backup-dir="$HOME/.tmp" -e /dev/null --progress "$@"
}

################################ vim ##################################################
if [ -x "$(command -v nvim)" ]; then
  alias vim="nvim"
fi

function zshrc() {
  vim "$HOME/dotfiles/zsh/zshrc"
}

function fvim() {
  vim "$(fzf)"
}

function codi() {
  local syntax="${1:-python}"
  shift
  vim -c \
    "let g:startify_disable_at_vimenter = 1 |\
    set bt=nofile ls=0 noru nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    Codi $syntax" "$@"
}

################################################## clipboard ###########################################################
if [[ "$(uname)" != "Darwin" ]]; then
  alias pbcopy='xclip -sel clip'
  alias pbpaste='xclip -selection clipboard -o'
fi
################################################# General stuff ########################################################
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

######################################### Docker ########################################
function docker-prune-volumes() {
  docker volume rm "$(docker volume ls -q --filter dangling=true)"
}

function dockerkill() {
  docker kill "$(docker ps -q)"
}

################################################## OSX Commands ########################################################

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS has no `md5sum`, so use `md5` as a fallback
  command -v md5sum >/dev/null || alias md5sum="md5"
  # macOS has no `sha1sum`, so use `shasum` as a fallback
  command -v sha1sum >/dev/null || alias sha1sum="shasum"
  command -v hd >/dev/null || alias hd="hexdump -C"
  alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"
  function flush() {
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
  }
fi

################################################ NODE ##################################################################
# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=~/.node_history
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768'
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy'

function node:scripts() {
  cat "$PWD/package.json" | jq .scripts
}

function n() {
  bash "$HOME/dotfiles/bin/nnn" $*
}

function ni() {
  if [[ "$#" == "0" ]]; then
    n install
  else
    n add -E "$@"
  fi
}

function types() {
  LIBS=$(for a in $@; do echo "@types/$a"; done)
  LIBS=$(echo "$LIBS" | tr '\n' ' ')
  ni -D $LIBS
}

################################ zellij ##################################################
function zedit() { zellij edit --floating "$*"; }

function zrun() { zellij run --name "$*" --floating -- zsh -ic "$*"; }

function zweb() { zellij --layout "$HOME/dotfiles/config/zlayouts/web.kdl"; }

function zkill() {
  zellij kill-all-sessions
  zellij delete-all-sessions
}

function zj() {
  ZJ_SESSIONS=$(zellij list-sessions)
  NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)
  if [ "${NO_SESSIONS}" -ge 2 ]; then
    zellij attach "$(echo "${ZJ_SESSIONS}" | fzf)"
  else
    zellij attach -c "$ZELLIJ_DEFAULT_SESSION"
  fi
}

function zinit() {
  local SESSION_NAME="${1-localhost}"
  zellij --session "$SESSION_NAME" attach -c "$SESSION_NAME"
}

##################################### Functions #####################################

function extract() {
  FILE="$1"
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

function listening() {
  if [ $# -eq 0 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P
  elif [ $# -eq 1 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color "$1"
  else
    echo "Usage: listening [pattern]"
  fi
}

alias listen=listening

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

function secretuuid() {
  echo -n "$1" | openssl enc -e -aes-256-cbc -a -salt | base64
}
