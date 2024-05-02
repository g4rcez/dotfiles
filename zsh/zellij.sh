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
    zellij --layout "$ZLAYOUT" --session "$SESSION_NAME" attach -c "$SESSION_NAME"
}

function zellij-start() {
    if [[ -z "$ZELLIJ" ]]; then
        if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
            zinit "$ZELLIJ_DEFAULT_SESSION"
        fi
    fi
}

function _zellij_tab_name_update() {
    if [[ -n $ZELLIJ ]]; then
        tab_name=''
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            tab_name+=$(basename "$(git rev-parse --show-toplevel)")/
            tab_name+=$(git rev-parse --show-prefix)
            tab_name=${tab_name%/}
        else
            tab_name=$PWD
            if [[ $tab_name == $HOME ]]; then
                tab_name="~"
            else
                tab_name=${tab_name##*/}
            fi
        fi
        command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
    fi
}
