#!/bin/bash
############################################################################
## aliases
alias cp='cp -v'
alias df='df -h'
alias diff='diff --color=auto'
alias dir='dir --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'
alias ls="lsd --git"
alias more='less'
alias mv='mv -v'
alias rm='rm -v'
alias vdir='vdir --color=auto'
alias wtf='pwd'
alias ll="ls -l"
alias cat="bat -p --pager cat"
alias dotfiles="cd $HOME/dotfiles"
alias secrets="ripsecrets"
# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

############################################################################
## vim
if [ -x "$(command -v nvim)" ]; then
    alias vim="nvim"
fi

function zshrc() {
    nvim "$HOME/dotfiles/zsh/zshrc"
}

function fvim() {
    nvim "$(fzf)"
}

function codi() {
    local syntax="${1:-typescript}"
    shift
    nvim -c \
        "let g:startify_disable_at_vimenter = 1 |\
    set bt=nofile ls=0 noru nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    Codi $syntax" "$@"
}

############################################################################
## linux
if [[ "$(uname)" != "Darwin" ]]; then
    alias pbcopy='xclip -sel clip'
    alias pbpaste='xclip -selection clipboard -o'
fi
############################################################################
## network
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

############################################################################
## docker
alias docker-compose="docker compose"
function docker-prune-volumes() {
    docker volume rm "$(docker volume ls -q --filter dangling=true)"
}

function dockerkill() {
    docker kill "$(docker ps -q)"
}

function fdocker() {
    docker ps -a | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $1 }' | xargs -r docker rm
}

############################################################################
## osx
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

############################################################################
## functions
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

function vivid-update() {
    echo "export LS_COLORS='$(vivid -d $DOTFILES/config/vivid/database.yml generate $DOTFILES/config/vivid/theme.yaml)'" >$DOTFILES/zsh/ls.sh
    echo "🚀 Vivid updated...New LS_COLORS are enabled"
}

function updateAll() {
    znap pull
    vivid-update
    nodeUpdatePackages
    fzf-update
    brew upgrade
}

function secretuuid() {
    echo -n "$1" | openssl enc -e -aes-256-cbc -a -salt | base64
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

function dotenv() {
    if [[ -f "$1" ]]; then
        set -o allexport
        source "$1"
        set +o allexport
    fi
}

function memory() {
    ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f MB ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
}

function cdm() {
    mkdir -p "$1"
    cd "$1" || return
}

function cpv() {
    rsync -pogbr -hhh --backup-dir="$HOME/.tmp" -e /dev/null --progress "$@"
}

function anon() {
    ZSH_AUTOSUGGEST_STRATEGY=()
}

function karabiner-reset() {
    launchctl stop org.pqrs.karabiner.karabiner_console_user_server
    sleep 0.5
    launchctl start org.pqrs.karabiner.karabiner_console_user_server
}
