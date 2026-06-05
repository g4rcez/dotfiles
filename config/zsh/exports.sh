#####################################################################################
## PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
if [[ -d "/opt/homebrew/opt/go/libexec" ]]; then
    export GOROOT="/opt/homebrew/opt/go/libexec"
else
    export GOROOT="$(brew --prefix go 2>/dev/null)/libexec"
fi
export GOPATH="$HOME/go"

PATH2="$PATH"

PATH_FILES=(
    "/usr/local/bin"
    "/opt/homebrew/bin"
    "$PNPM_HOME"
    "$PNPM_HOME/bin"
    "$GOPATH/bin"
    "$GOROOT/bin"
    "$HOME/.bun/bin"
    "$HOME/.cargo/env"
    "$HOME/.dotnet"
    "$HOME/.dotnet/tools"
    "$HOME/.local/bin"
    "$HOME/.local/share"
    "$HOME/.local/share/bin"
    "$HOME/tools"
    "$HOME/dotfiles/bin"
    "$HOME/tools/google-cloud-sdk/bin"
    "$HOME/.antigravity/antigravity/bin"
    "$HOME/.opencode/bin"
)

for SOURCE_FILE in "${PATH_FILES[@]}"; do
    if [[ -d "$SOURCE_FILE" ]]; then
        PATH2="$PATH2:$SOURCE_FILE"
    fi
done

PATH="$PATH2"
export PATH="$PATH2"

#####################################################################################
## Important exports
export LISTMAX=10000
export DOTFILES="$HOME/dotfiles"
export DOTFILES_DIR="$HOME/dotfiles"
export TS_SCRIPTS="$HOME/dotfiles/bin"
export ZSH="$HOME/.zsh/plugins/ohmyzsh/ohmyzsh"
export PLUGINS_DIR="$HOME/.zsh/plugins"
export SNAP_DIR="$PLUGINS_DIR/znap"
export BROWSER=""
export GPG_TTY=$TTY
export CASE_SENSITIVE="false"
export HIST_STAMPS="yyyy-mm-dd"
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export ENABLE_CORRECTION="true"
export HYPHEN_INSENSITIVE="true"
export KEYTIMEOUT=1000
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_COLLATE=C
export MANPATH="/usr/local/man:$MANPATH"
export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/libpq/lib/pkgconfig"

#####################################################################################
## ZELLIJ_CONFIG
export ZELLIJ_AUTO_ATTACH=false
export ZELLIJ_AUTO_EXIT=false
export ZELLIJ_DEFAULT_SESSION="localhost"

#####################################################################################
## ZSH_PLUGINS
# `zsh-autosuggestions`' completion strategy toggles tty line-discipline while
# it probes completions. That can leave Kitty/Ghostty outside tmux with output
# no longer returning to column 0 after Enter, so only enable the completion
# strategy when we're already inside tmux.
if [[ -n "$TMUX" ]]; then
    export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
else
    export ZSH_AUTOSUGGEST_STRATEGY=(history)
fi
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line regexp)
export ZSH_TMUX_AUTOSTART="true"
export ZSH_TMUX_CONFIG="$DOTFILES/config/tmux/tmux.conf"
export ZSH_TMUX_DEFAULT_SESSION_NAME="localhost"
export ZSH_TMUX_FIXTERM="true"

#####################################################################################
## Auto notify plugin
export AUTO_NOTIFY_BODY="Completed in %elapseds - Exit code %exit_code"
export AUTO_NOTIFY_EXPIRE_TIME=5000
export AUTO_NOTIFY_IGNORE=("vim" "ssh" "st" "fzf" "nvim" "mvim" "neovim" "zshrc" "zellij")
export AUTO_NOTIFY_THRESHOLD=10000
export AUTO_NOTIFY_TITLE="%command - Finished"

#####################################################################################
## Cat + Bat + Less + Man
export BAT_PAGER="less"
export DELTA_PAGER="less -R"
export EDITOR="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PAGER=""
if (( $+commands[nvim] )); then
    export EDITOR="nvim"
    export MANPAGER="nvim +Man!"
    export PAGER="nvim"
fi

#####################################################################################
## other utils stuff
export BUN_INSTALL="$HOME/.bun"
export LESSOPEN='|~/dotfiles/bin/lessfilter.sh %s'
export YSU_MESSAGE_POSITION="after"
export MISE_NODE_DEFAULT_PACKAGES_FILE="$DOTFILES/config/mise/defaults/node"
if [ -x "$(command -v podman)" ]; then
    export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
fi
#####################################################################################
## ai
unset ANTHROPIC_API_KEY  # force RTK proxy auth routing — do not restore
export ENABLE_LSP_TOOL=1
export AI_CLI_NAME="gemini"
export AI_CLI_MODEL="gemini-3-flash-preview"
export AI_QUERY_COMMAND="gemini --model gemini-3-flash-preview -p"
export USE_BUILTIN_RIPGREP=0

export AICOMMIT_EXCLUDES=(
    "package-lock.json"
    "pnpm-lock.yaml"
    "yarn.lock"
    "*.lock"
)

source "$DOTFILES/config/zsh/ls.sh"
