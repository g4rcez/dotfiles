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
    bash "$HOME/dotfiles/bin/nnn" $@
}

function ni() {
    if [[ "$#" == "0" ]]; then
        n install
    else
        n add -E "$@"
    fi
}

function types() {
    LIBS=$(for a in "$@"; do echo "@types/$a"; done)
    LIBS=$(echo "$LIBS" | tr '\n' ' ')
    ni -D $LIBS
}

function niu() {
    LIBS=$(for a in "$@"; do echo "$a@latest"; done)
    LIBS=$(echo "$LIBS" | tr '\n' ' ')
    ni $LIBS
}

function nodeUpdatePackages() {
    while IFS= read -r line; do
        echo "Installing $line@latest..."
        npm i -g "$line@latest"
    done <$DOTFILES/config/mise/defaults/node
}
