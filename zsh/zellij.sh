ZLAYOUT="$HOME/dotfiles/config/zellij/status.kdl "

function zedit() {
  zellij edit --floating "$*"
}

function zrun() {
  NAME=$(echo "$1" | cut -d ' ' -f1)
  zellij run --name "$NAME" --floating -- zsh -i -c "$*"
}

function zweb() {
  zellij --layout "$HOME/dotfiles/config/zlayouts/web.kdl"
}

function zkill() {
  zellij kill-all-sessions
  zellij delete-all-sessions
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
