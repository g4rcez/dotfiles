ZLAYOUT="$HOME/dotfiles/config/zellij/layouts/default.kdl"

function zedit() {
    zellij edit --floating "$*"
}

function zrun() {
    NAME=$(echo "$1" | cut -d ' ' -f1)
    zellij run --name "$NAME" --floating -- zsh -i -c "$*"
}

function zkill() {
    zellij kill-all-sessions --yes
    zellij delete-all-sessions --force --yes
}

function zj() {
    ZJ_SESSIONS=$(zellij list-sessions)
    NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)
    if [ "${NO_SESSIONS}" -ge 2 ]; then
        zellij --layout "$ZLAYOUT" attach "$(echo "${ZJ_SESSIONS}" | fzf)"
    else
        zellij --layout "$ZLAYOUT" attach -c "$ZELLIJ_DEFAULT_SESSION"
    fi
}

function zinit() {
    local SESSION_NAME="${1-localhost}"
    local CURRENT_WORK_DIR="${2-$HOME}"
    zellij --layout "$ZLAYOUT" attach "$SESSION_NAME" options --session-name "$SESSION_NAME" --default-cwd "$CURRENT_WORK_DIR"
}

function zellij-start() {
    if [[ -z "$ZELLIJ" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            zinit "$ZELLIJ_DEFAULT_SESSION" "$HOME/dotfiles"
        fi
    fi
}

function zr() {
    zellij run --name "$*" -- zsh -ic "$*"
}

function zrf() {
    zellij run --name "$*" --floating -- zsh -ic "$*"
}

function zri() {
    zellij run --name "$*" --in-place -- zsh -ic "$*"
}

function ze() {
    zellij edit "$*"
}

function zef() {
    zellij edit --floating "$*"
}

function zei() {
    zellij edit --in-place "$*"
}

function zpipe() {
    if [ -z "$1" ]; then
        zellij pipe
    else
        zellij pipe -p $1
    fi
}

function zcheck () {
    mkdir -p ~/.config/zellij/plugins && curl -L "https://github.com/stretch/zbuffers/releases/latest/download/zbuffers.wasm" -o ~/.config/zellij/plugins/zbuffers.wasm
    mkdir -p ~/.config/zellij/plugins && curl -L "https://github.com/rvcas/room/releases/latest/download/room.wasm" -o ~/.config/zellij/plugins/room.wasm
}
