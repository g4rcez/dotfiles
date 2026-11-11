#!/bin/zsh
############################################################################
## overrides
if (($+commands[podman])); then
    alias docker='podman'
fi
alias docker-compose="docker compose"
############################################################################
## aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'
############################################################################
## aliases
alias cp='cp -v'
alias df='df -h'
# These flags are GNU-specific; keep the aliases off BSD/macOS tools.
if [[ "$OSTYPE" == linux* ]]; then
    alias diff='diff --color=auto'
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ip='ip --color=auto'
    alias vdir='vdir --color=auto'
fi
alias ls="lsd"
alias more='less'
alias mv='mv -v'
alias rm='rm -v'
alias dotfiles.doctor='dotfiles-doctor'
alias wtf='pwd'
alias ll="ls -l"
alias cat="bat -p --pager cat"
alias dotfiles='cd -- "$DOTFILES"'
alias costs='bun run "$HOME/.pi/costs.ts"'
alias secrets="ripsecrets"
# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
# Reload the shell (i.e. invoke as a login shell)
# Drop inherited AI_* defaults so exports.sh recomputes them; a plain `exec` keeps stale values.
alias reload='exec env -u AI_CLI_NAME -u AI_CLI_MODEL -u AI_COMMIT_MODEL -u AI_COMMAND_PROMPT -u AI_QUERY_COMMAND "$SHELL" -l'
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
alias dockers='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias worktree="workmux"

function zshrc() {
    nvim "$DOTFILES/config/zsh/zshrc"
}

############################################################################
## linux
if [[ "$OSTYPE" != darwin* ]] && (($+commands[xclip])); then
    alias pbcopy='xclip -sel clip'
    alias pbpaste='xclip -selection clipboard -o'
fi
############################################################################
## network
alias remoteip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

############################################################################
## osx
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS has no `md5sum`, so use `md5` as a fallback
    command -v md5sum >/dev/null || alias md5sum="md5"
    # macOS has no `sha1sum`, so use `shasum` as a fallback
    command -v sha1sum >/dev/null || alias sha1sum="shasum"
    command -v hd >/dev/null || alias hd="hexdump -C"
    alias dsclean="find . -type f -name '*.DS_Store' -ls -delete"
fi

function dotenv() {
    emulate -L zsh
    setopt localoptions allexport

    if (($# != 1)); then
        print -u2 -r -- "Usage: dotenv TRUSTED_FILE"
        return 2
    fi
    if [[ ! -r "$1" ]]; then
        print -u2 -r -- "dotenv: file is not readable: $1"
        return 1
    fi
    source "$1" || {
        print -u2 -r -- "dotenv: failed to load $1"
        return 1
    }
}

function cdm() {
    mkdir -p "$1"
    cd "$1" || return
}

function anon() {
    export ZSH_AUTOSUGGEST_STRATEGY=()
}

function brewfix() {
    brew cleanup && rm -f $ZSH_COMPDUMP && omz reload
}

function tmux-start() {
    tmux -S "$TMUX_SOCKET_PATH" new-session -A -s localhost
}

function _tmux_preexec_command_name() {
    emulate -L zsh
    [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]] || return 0

    local line="${1:-}"
    local word cmd=""
    while [[ -n "$line" ]]; do
        line="${line#${line%%[![:space:]]*}}"
        word="${line%%[[:space:]]*}"
        line="${line#"$word"}"

        case "$word" in
        "" | *=* | -* | command | exec | noglob | builtin | time | sudo | env) continue ;;
        *)
            cmd="${word:t}"
            break
            ;;
        esac
    done

    [[ -n "$cmd" ]] || return 0
    tmux -S "$TMUX_SOCKET_PATH" set-option -pq -t "$TMUX_PANE" @zsh_current_command "$cmd" 2>/dev/null || true
    tmux -S "$TMUX_SOCKET_PATH" refresh-client -S 2>/dev/null || true
}
autoload -Uz add-zsh-hook
add-zsh-hook -d preexec _tmux_preexec_command_name 2>/dev/null
add-zsh-hook preexec _tmux_preexec_command_name

function _tmux_precmd_clear_command_name() {
    emulate -L zsh
    [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]] || return 0
    tmux -S "$TMUX_SOCKET_PATH" set-option -pqu -t "$TMUX_PANE" @zsh_current_command 2>/dev/null || true
}
add-zsh-hook -d precmd _tmux_precmd_clear_command_name 2>/dev/null
add-zsh-hook precmd _tmux_precmd_clear_command_name

function _rm_safety_prompt() {
    emulate -L zsh
    [[ -o interactive ]] || return 0
    [[ "$1" == rm\ * || "$1" == rm || "$1" == command\ rm\ * ]] || return 0

    local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"
    local today
    today="$(date +%F)"
    local state_file="$state_dir/rm-count-$today"
    mkdir -p "$state_dir"

    local count=0
    [[ -f "$state_file" ]] && count="$(<"$state_file")"
    count=$((count + 1))
    print -r -- "$count" >|"$state_file"

    if ((count == 5)); then
        print -P "%F{yellow}rm used $count times today. Consider rmx dry-run, rmx trash, or a repo-local cleanup script.%f"
    fi
}
add-zsh-hook -d preexec _rm_safety_prompt 2>/dev/null
add-zsh-hook preexec _rm_safety_prompt

function ask_ai() {
    ${=AI_QUERY_COMMAND} "$@"
}

alias '??'="ask_ai"
alias code.="code ."

# Local, untracked task boundary notes live inside each Git worktree's .git dir.
alias checkpoint='task-checkpoint'
alias checkpoint-show='task-checkpoint show'
alias checkpoint-clear='task-checkpoint clear'

_cdm() {
    _arguments '1:directory:_directories'
}

compdef _files dotenv
compdef _cdm cdm
