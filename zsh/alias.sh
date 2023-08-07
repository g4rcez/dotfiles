#!/bin/bash
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
alias logs="forgit::log"

function gitignore() {
  forgit::ignore >> .gitignore
}

function git-graph() {
  git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
}

function clone() {
  git clone "git@github.com:$1"
}

function tag() {
  git tag "$1" && git push origin "$1"
}

######################### *nix alias #########################
alias cp='cp -v'
alias df='df -h'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias ls="exa --icons --git --color=always -bghHiS"
alias more='less'
alias mv='mv -v'
alias rm='rm -v'
alias vdir='vdir --color=auto'
alias wtf='pwd'
alias ll="ls -l"
alias ccat="cat"
alias cat="bat -p --pager cat --theme OneHalfDark"
# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
alias bottom='btm'

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

########################## CLIPBOARD ##########################################
if [[ "$(uname)" != "Darwin" ]]; then
  alias pbcopy='xclip -sel clip'
  alias pbpaste='xclip -selection clipboard -o'
fi
######################### General stuff #########################
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

if [ -x "$(command -v lvim)" ]; then
  alias vim="lvim"
fi

function fvim() {
  vim "$(fzf)"
}

######################################### Docker ########################################
function docker-prune-volumes () {
  docker volume rm $(docker volume ls -q --filter dangling=true)
}

function dockerkill () {
  docker kill $(docker ps -q)
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
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

alias listen=listening

function cdf() { # short for `cdfinder`
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

function zshrc() {
  vim "$HOME/dotfiles/zsh/zshrc"
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

function secretuuid() {
  echo -n "$1" | openssl enc -e -aes-256-cbc -a -salt | base64
}

################################### OSX Commands ##########################################

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS has no `md5sum`, so use `md5` as a fallback
  command -v md5sum >/dev/null || alias md5sum="md5"
  # macOS has no `sha1sum`, so use `shasum` as a fallback
  command -v sha1sum >/dev/null || alias sha1sum="shasum"
  command -v hd > /dev/null || alias hd="hexdump -C"
  command -v python > /dev/null || alias python="python3"
  alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"
  function flush () {
    sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
  }
fi

######################################## FZF ####################################################
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
-i
--border
--info=inline
--layout=reverse
--height 90%
--color=dark
--color header:italic
--preview '~/dotfiles/bin/lessfilter.sh {}'
--preview-window right,70%
--bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)'
--bind 'ctrl-/:toggle-preview'
--color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672 "
export FORGIT_FZF_DEFAULT_OPTS="--ansi --exact --border --cycle --reverse --height '80%' --preview-window right,50%"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

function st() {
  git rev-parse --git-dir > /dev/null 2>&1 || { echo "You are not in a git repository" && return; }
  local selected
  selected=$(git -c color.status=always status --short |
    fzf --no-height "$@" --border -m --ansi --nth 2..,.. --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
    cut -c4- | sed 's/.* -> //')
    if [[ $selected ]]; then
      for prog in $(echo $selected);
      do $EDITOR $prog; done;
  fi
}

function fzf-eval(){
  echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

function fns() {
  if [[ -f package.json ]]; then
  local CONTENT="$(jq -r '.scripts' package.json)"
  local script=$(jq -r '.scripts | keys[] ' package.json | sort -u | fzf --preview="echo '$CONTENT'") && n $(echo "$script")
  fi
}

function fzf-update () {
  DIR="$(pwd)"
  cd ~/.fzf && git pull && ./install
  cd "$DIR"
  exec $SHELL -l
}

function files(){
  local file=$(fzf --multi --reverse);
  if [[ $file ]]; then
    for prog in $(echo $file);
    do $EDITOR $prog; done;
  else
    echo "cancelled fzf"
  fi
}

bindkey -s "^F" 'files^M'
bindkey "^[[Z" expand-or-complete;
bindkey "^I" expand-or-complete;
bindkey "^ " fzf-tab-complete;

################################ NODE ##################################

# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=~/.node_history;
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768';
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy';

function node:scripts() {
  cat "$PWD/package.json" | jq .scripts
}

function n() {
  local COMMAND=""
  local SUBCOMMAND="$1"; shift;
  local INSTALL_COMMAND="add"
  local PRE=""
  local ARGUMENTS="-E"
  if [[ -f "package-lock.json" ]]; then
    COMMAND="npm";
    RUN_ARGS=".scripts.$SUBCOMMAND"
    if [[ "$(jq "$RUN_ARGS" package.json)" != "" ]]; then PRE="run"; fi
    INSTALL_COMMAND="install";
  fi
  if [[ -f "yarn.lock" ]]; then COMMAND="yarn"; fi
  if [[ -f "pnpm-lock.yaml" ]]; then COMMAND="pnpm"; fi
  if [[ "$#" == "0" ]];then
    ARGUMENTS=""
  fi
  case $SUBCOMMAND in
    "add") "$COMMAND" $INSTALL_COMMAND $ARGUMENTS $@;;
    "i") "$COMMAND" install $ARGUMENTS $@;;
    "install") "$COMMAND" install $ARGUMENTS $@;;
    *) $COMMAND $PRE $SUBCOMMAND "$@";;
  esac
}

function ni() {
  if [[ "$#" == "0" ]]; then
    n install;
  else
    n add -E "$@";
  fi
}

################################ tmux ##################################################
alias tsource="tmux source $HOME/.tmux.conf"

function unbindall() {
  for table in prefix root copy-mode copy-mode-vi; do
      tmux unbind -a -T "$table"
  done
}

################################ zellij ##################################################

function zj() {
  ZJ_SESSIONS=$(zellij list-sessions)
  NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)
  if [ "${NO_SESSIONS}" -ge 2 ]; then
      zellij attach \
      "$(echo "${ZJ_SESSIONS}" | fzf)"
  else
     zellij attach -c localhost
  fi
}

function zinit() { zellij attach -c "${1-localhost}"; }
function zr() { zellij run --name "$*" -- zsh -ic "$*";}
function run() { zellij run --name "$*" -- zsh -ic "$*";}
function zrf() { zellij run --name "$*" --floating -- zsh -ic "$*";}
function ze() { zellij edit "$*";}
function zef() { zellij edit --floating "$*";}

##################################### dotnet autocomplete ################################
function _dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi
  _values = "${(ps:\n:)completions}"
}

