# Paths of the zsh config. Sourced by config/zsh/utils.sh and bin/zshx.

function _zsh_config_root() {
    emulate -L zsh
    print -r -- "${DOTFILES:-$PWD}/config/zsh"
}

function _zsh_config_sources() {
    emulate -L zsh
    local root="${1:-$(_zsh_config_root)}"
    [[ -f "$root/zshrc" ]] && print -r -- "$root/zshrc"
    command find "$root" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.zsh' \) -print 2>/dev/null | command sort
    if [[ -d "$root/completion" ]]; then
        command find "$root/completion" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.zsh' \) -print 2>/dev/null | command sort
    fi
}
