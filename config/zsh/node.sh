# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=~/.node_history
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768'
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy'

function node:scripts() {
    jq .scripts "$PWD/package.json"
}

function n() {
    bash "$DOTFILES/bin/nnn" "$@"
}

function ni() {
    if [[ "$#" == "0" ]]; then
        n install
    else
        n add -E "$@"
    fi
}

function types() {
    local -a libs=()
    local package
    for package in "$@"; do
        libs+=("@types/$package")
    done
    ((${#libs[@]})) && ni -D "${libs[@]}"
}

function niu() {
    local -a packages=()
    local package
    for package in "$@"; do
        packages+=("$package@latest")
    done
    ((${#packages[@]})) && ni "${packages[@]}"
}

function nodeUpdatePackages() {
    while IFS= read -r line; do
        echo "Installing $line@latest..."
        npm i -g "$line@latest"
    done <$DOTFILES/config/mise/defaults/node
}
