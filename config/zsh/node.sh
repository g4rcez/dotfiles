# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=~/.node_history
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768'
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy'

# Preserve ownership across nested shells so they can remove this PATH entry.
typeset -gx _zsh_node_modules_bin="${_zsh_node_modules_bin:-}"
function _zsh_node_modules_bin_update() {
    emulate -L zsh

    local project_dir="$PWD"
    local node_bin=''
    local old_node_bin="$_zsh_node_modules_bin"
    local old_path_present=0
    local entry
    while true; do
        if [[ -f "$project_dir/package.json" ]]; then
            node_bin="${project_dir%/}/node_modules/.bin"
            break
        fi
        [[ "$project_dir" == / ]] && break
        project_dir="${project_dir:h}"
    done

    if [[ -n "$old_node_bin" ]]; then
        for entry in "${path[@]}"; do
            if [[ "$entry" == "$old_node_bin" ]]; then
                old_path_present=1
                break
            fi
        done
        if ((! old_path_present)); then
            old_node_bin=''
            _zsh_node_modules_bin=''
        fi
    fi

    [[ -n "$old_node_bin" && "$node_bin" == "$old_node_bin" ]] && return 0

    if [[ -n "$old_node_bin" ]]; then
        local -a updated_path=()
        for entry in "${path[@]}"; do
            [[ "$entry" == "$old_node_bin" ]] || updated_path+=("$entry")
        done
        path=("${updated_path[@]}")
    fi

    _zsh_node_modules_bin=''
    if [[ -n "$node_bin" ]]; then
        for entry in "${path[@]}"; do
            [[ "$entry" == "$node_bin" ]] && {
                rehash
                return 0
            }
        done
        path=("$node_bin" "${path[@]}")
        _zsh_node_modules_bin="$node_bin"
    fi
    rehash
}

autoload -Uz add-zsh-hook
add-zsh-hook -d chpwd _zsh_node_modules_bin_update 2>/dev/null
add-zsh-hook chpwd _zsh_node_modules_bin_update
_zsh_node_modules_bin_update

function n() {
    bash "$DOTFILES/bin/nnn" "$@"
}
