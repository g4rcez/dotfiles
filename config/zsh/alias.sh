#!/bin/zsh
## directories
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
alias reload="exec ${SHELL} -l"
# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
if (($+commands[podman])); then
    alias docker='podman'
fi
alias dockers='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

############################################################################
## vim
if (($+commands[nvim])); then
    alias vim="nvim"
fi

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
## docker
alias docker-compose="docker compose"
function docker-prune-volumes() {
    emulate -L zsh
    local confirm=0
    case "${1:-}" in
    --confirm | -y)
        confirm=1
        shift
        ;;
    --dry-run | "") ;;
    *)
        print -u2 -r -- "Usage: docker-prune-volumes [--dry-run|--confirm]"
        return 2
        ;;
    esac

    local volume_output
    volume_output="$(docker volume ls -q --filter dangling=true)" || return $?
    local -a volumes=()
    local volume
    while IFS= read -r volume; do
        [[ -n "$volume" ]] && volumes+=("$volume")
    done <<<"$volume_output"
    if ((${#volumes[@]} == 0)); then
        print -r -- "no dangling volumes"
        return 0
    fi
    print -rl -- "${volumes[@]}"
    if ((!confirm)); then
        print -r -- "dry-run; rerun with --confirm to remove these volumes"
        return 0
    fi
    docker volume rm -- "${volumes[@]}"
}

function dockerkill() {
    emulate -L zsh
    local confirm=0
    case "${1:-}" in
    --confirm | -y)
        confirm=1
        shift
        ;;
    --dry-run | "") ;;
    *)
        print -u2 -r -- "Usage: dockerkill [--dry-run|--confirm]"
        return 2
        ;;
    esac
    (($# == 0)) || {
        print -u2 -r -- "Usage: dockerkill [--dry-run|--confirm]"
        return 2
    }

    local container_output
    container_output="$(docker ps -q)" || return $?
    local -a containers=()
    local container
    while IFS= read -r container; do
        [[ -n "$container" ]] && containers+=("$container")
    done <<<"$container_output"
    if ((${#containers[@]} == 0)); then
        print -r -- "no running containers"
        return 0
    fi
    print -rl -- "${containers[@]}"
    if ((!confirm)); then
        print -r -- "dry-run; rerun with --confirm to kill these containers"
        return 0
    fi
    docker kill -- "${containers[@]}"
}

function fdocker() {
    emulate -L zsh
    local confirm=0
    if [[ "${1:-}" == --confirm ]]; then
        confirm=1
        shift
    fi

    local selected
    selected="$(docker ps -a | sed 1d | fzf -q "${1:-}" --no-sort -m --tac | awk '{ print $1 }')" || return $?
    local -a containers=()
    local container
    while IFS= read -r container; do
        [[ -n "$container" ]] && containers+=("$container")
    done <<<"$selected"
    ((${#containers[@]})) || return 0
    print -rl -- "${containers[@]}"
    if ((!confirm)); then
        print -r -- "dry-run; rerun fdocker --confirm [query] to remove these containers"
        return 0
    fi
    docker rm -- "${containers[@]}"
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
    local FILE="$1"
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
        sudo lsof -iTCP -sTCP:LISTEN -n -P | command grep -i -- "$1"
    else
        echo "Usage: listening [pattern]"
    fi
}

function vivid-update() {
    (($+commands[vivid])) || {
        print -u2 -r -- "vivid-update: vivid is not installed"
        return 1
    }

    local target="$DOTFILES/config/zsh/ls.sh"
    local colors temp
    colors="$(command vivid -d "$DOTFILES/config/vivid/database.yml" generate "$DOTFILES/config/vivid/theme.yaml")" || return $?
    temp="$(command mktemp "$target.XXXXXX")" || return $?
    if ! printf "export LS_COLORS='%s'\\n" "$colors" >|"$temp"; then
        command rm -f -- "$temp"
        return 1
    fi
    if ! command mv -f -- "$temp" "$target"; then
        command rm -f -- "$temp"
        return 1
    fi
    print -r -- "vivid updated; restart or reload zsh to apply the new LS_COLORS"
}

function updateAll() {
    vivid-update || return
    (($+commands[mise])) && command mise self-update
    (($+commands[npm])) && nodeUpdatePackages
    if (($+commands[brew])); then
        command brew update && command brew upgrade
    fi
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
    if (($# > 0)); then
        du "$arg" -- "$@"
    else
        du $arg .[^.]* ./*
    fi
}

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

function memory() {
    ps -eo pid,rss,comm -m | awk 'NR==1{printf "%6s %10s  %s\n",$1,$2,$3} NR>1{printf "%6d %8.2f MB  %s\n",$1,$2/1024,$3}' | head -30
}

function cdm() {
    mkdir -p "$1"
    cd "$1" || return
}

function cpv() {
    rsync -pogbr -hhh --backup-dir="$HOME/.tmp" -e /dev/null --progress "$@"
}

function anon() {
    export ZSH_AUTOSUGGEST_STRATEGY=()
}

function karabiner-reset() {
    launchctl stop org.pqrs.karabiner.karabiner_console_user_server
    sleep 0.5
    launchctl start org.pqrs.karabiner.karabiner_console_user_server
}

function brewfix() {
    brew cleanup && rm -f $ZSH_COMPDUMP && omz reload
}

function tmux-start() {
    tmux -S "$HOME/.tmp/socket" new-session -A -s localhost
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
    tmux set-option -pq -t "$TMUX_PANE" @zsh_current_command "$cmd" 2>/dev/null || true
    tmux refresh-client -S 2>/dev/null || true
}
autoload -Uz add-zsh-hook
add-zsh-hook -d preexec _tmux_preexec_command_name 2>/dev/null
add-zsh-hook preexec _tmux_preexec_command_name

function _tmux_precmd_clear_command_name() {
    emulate -L zsh
    [[ -n "${TMUX:-}" && -n "${TMUX_PANE:-}" ]] || return 0
    tmux set-option -pqu -t "$TMUX_PANE" @zsh_current_command 2>/dev/null || true
}
add-zsh-hook -d precmd _tmux_precmd_clear_command_name 2>/dev/null
add-zsh-hook precmd _tmux_precmd_clear_command_name

function killport() {
    emulate -L zsh
    if (($# != 1)) || [[ ! "$1" =~ '^[0-9]+$' ]]; then
        print -u2 -r -- "Usage: killport PORT"
        return 2
    fi

    local -a pids=()
    local pid
    while IFS= read -r pid; do
        [[ -n "$pid" ]] && pids+=("$pid")
    done < <(lsof -ti:"$1" 2>/dev/null)
    ((${#pids[@]})) || {
        print -r -- "no process listening on $1"
        return 0
    }
    for pid in "${pids[@]}"; do
        kill -9 "$pid" || return $?
    done
    print -r -- "killed $1"
}

function psgrep() {
    ps aux | grep -i "$1" | grep -v grep
}

function rm:dry-run() {
    emulate -L zsh
    if (($# == 0)); then
        print -u2 -r -- "Usage: rm:dry-run PATH [...]"
        return 2
    fi

    local target
    for target in "$@"; do
        if [[ -e "$target" || -L "$target" ]]; then
            print -r -- "would remove: $target"
        else
            print -r -- "missing: $target"
        fi
    done
}

function rm:trash() {
    emulate -L zsh
    if (($# == 0)); then
        print -u2 -r -- "Usage: rm:trash PATH [...]"
        return 2
    fi

    if (($ + commands[trash])); then
        command trash "$@"
    else
        local trash_dir="$HOME/.Trash"
        [[ -d "$trash_dir" ]] || mkdir -p "$trash_dir"
        command mv -v -- "$@" "$trash_dir/"
    fi
}

function rm:safe() {
    emulate -L zsh
    if (($# == 0)); then
        print -u2 -r -- "Usage: rm:safe PATH [...]"
        return 2
    fi

    rm:dry-run "$@"
    print -r -- "Use rm:trash to move these paths to Trash, or command rm to delete permanently."
}

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
        print -P "%F{yellow}rm used $count times today. Consider rm:dry-run, rm:trash, or a repo-local cleanup script.%f"
    fi
}
add-zsh-hook -d preexec _rm_safety_prompt 2>/dev/null
add-zsh-hook preexec _rm_safety_prompt

function killnodemodules() {
    find . -name 'node_modules' -type d -prune -print
    print -r -- "Use rm:trash on selected paths, or run: find . -name 'node_modules' -type d -prune -exec command rm -rf {} +"
}

function npm.kill() {
    killnodemodules
}

function ask_ai() {
    ${=AI_QUERY_COMMAND} "$@"
}
alias '??'="ask_ai"
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# Local, untracked task boundary notes live inside each Git worktree's .git dir.
alias checkpoint='task-checkpoint'
alias checkpoint-show='task-checkpoint show'
alias checkpoint-clear='task-checkpoint clear'

function worktree() {
    case "${1:-}" in
    add)
        command worktree "$@" || return $?
        [[ -n "${2:-}" ]] || return 0
        local p
        p="$(command worktree cd "$2" 2>/dev/null)" || return 0
        [[ -d "$p" ]] && cd "$p"
        ;;
    cd)
        local p
        p="$(command worktree cd "${2:-}")" || return $?
        [[ -d "$p" ]] && cd "$p"
        ;;
    *)
        command worktree "$@"
        ;;
    esac
}

_killport() {
    local -a ports=()
    local port
    while IFS= read -r port; do
        [[ -n "$port" ]] && ports+=("$port")
    done < <(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR > 1 { n = split($9, a, ":"); if (a[n] ~ /^[0-9]+$/) print a[n] ":" $1 }' | sort -u)

    _describe 'listening port' ports
}

_process_names() {
    local -a processes=()
    local process
    while IFS= read -r process; do
        [[ -n "$process" ]] && processes+=("$process:$process")
    done < <(ps -axo comm= 2>/dev/null | sed 's#.*/##' | sort -u)

    _describe 'process' processes
}

_cdm() {
    _arguments '1:directory:_directories'
}

compdef _files extract fs dotenv cpv rm:dry-run rm:trash rm:safe
compdef _cdm cdm
compdef _killport killport
compdef _process_names listening psgrep
