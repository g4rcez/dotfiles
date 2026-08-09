#####################################################################################
## repository and PATH
if [[ -z "${DOTFILES:-}" || ! -d "$DOTFILES/config/zsh" ]]; then
    if [[ -n "${DOTFILES_DIR:-}" && -d "$DOTFILES_DIR/config/zsh" ]]; then
        DOTFILES="$DOTFILES_DIR"
    else
        DOTFILES="${DOTFILES_DIR:-$PWD}"
    fi
fi
export DOTFILES
if [[ -z "${DOTFILES_DIR:-}" || ! -d "$DOTFILES_DIR/config/zsh" ]]; then
    DOTFILES_DIR="$DOTFILES"
fi
export DOTFILES_DIR

export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export GOPATH="${GOPATH:-$HOME/go}"

if [[ -z "${GOROOT:-}" ]]; then
    typeset -a _go_roots=(
        "/opt/homebrew/opt/go/libexec"
        "/usr/local/opt/go/libexec"
    )
    for _go_root in "${_go_roots[@]}"; do
        if [[ -d "$_go_root" ]]; then
            export GOROOT="$_go_root"
            break
        fi
    done
    unset _go_roots _go_root
fi

typeset -gU path PATH
typeset -a _path_entries=(
    "/usr/local/bin"
    "/opt/homebrew/bin"
    "$PNPM_HOME"
    "$PNPM_HOME/bin"
    "$GOPATH/bin"
    "${GOROOT:+$GOROOT/bin}"
    "$HOME/tools"
    "$HOME/.dotnet"
    "$HOME/.dotnet/tools"
    "$HOME/.bun/bin"
    "$HOME/.cargo/bin"
    "$DOTFILES/bin"
    "$HOME/.local/bin"
    "$HOME/.grok/bin"
    "$HOME/.local/share"
    "$HOME/.opencode/bin"
    "$HOME/.local/share/bin"
)
for _path_entry in "${_path_entries[@]}"; do
    [[ -n "$_path_entry" && -d "$_path_entry" ]] && path+=("$_path_entry")
done
unset _path_entries _path_entry
export PATH

#####################################################################################
## Important exports
export WEZTERM_CONFIG_DIR="$DOTFILES/config/wezterm"
export WEZTERM_CONFIG_FILE="$DOTFILES/config/wezterm/wezterm.lua"
export LISTMAX="${LISTMAX:-100000}"
export TS_SCRIPTS="${TS_SCRIPTS:-$DOTFILES/bin}"
export ZSH="${ZSH:-$HOME/.zsh/plugins/ohmyzsh/ohmyzsh}"
export PLUGINS_DIR="${PLUGINS_DIR:-$HOME/.zsh/plugins}"
export SNAP_DIR="${SNAP_DIR:-$PLUGINS_DIR/znap}"
export GPG_TTY="${GPG_TTY:-$TTY}"
export CASE_SENSITIVE="${CASE_SENSITIVE:-false}"
export HIST_STAMPS="${HIST_STAMPS:-yyyy-mm-dd}"
export DISABLE_UNTRACKED_FILES_DIRTY="${DISABLE_UNTRACKED_FILES_DIRTY:-true}"
export ENABLE_CORRECTION="${ENABLE_CORRECTION:-true}"
export HYPHEN_INSENSITIVE="${HYPHEN_INSENSITIVE:-true}"
export KEYTIMEOUT="${KEYTIMEOUT:-1000}"
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LC_COLLATE="${LC_COLLATE:-C}"

# Only add the conventional macOS man directory when it exists; preserve a
# user's existing MANPATH and compiler flags.
if [[ -d "/usr/local/man" && -z "${MANPATH:-}" ]]; then
    export MANPATH="/usr/local/man"
elif [[ -d "/usr/local/man" && ":${MANPATH}:" != *":/usr/local/man:"* ]]; then
    export MANPATH="$MANPATH:/usr/local/man"
fi
if [[ -d "/opt/homebrew/opt/libpq/lib" ]]; then
    [[ "${LDFLAGS:-}" == *-L/opt/homebrew/opt/libpq/lib* ]] ||
        export LDFLAGS="${LDFLAGS:+$LDFLAGS }-L/opt/homebrew/opt/libpq/lib"
    [[ "${CPPFLAGS:-}" == *-I/opt/homebrew/opt/libpq/include* ]] ||
        export CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }-I/opt/homebrew/opt/libpq/include"
    [[ ":${PKG_CONFIG_PATH:-}:" == *:/opt/homebrew/opt/libpq/lib/pkgconfig:* ]] ||
        export PKG_CONFIG_PATH="/opt/homebrew/opt/libpq/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
fi

#####################################################################################
## ZELLIJ_CONFIG
export ZELLIJ_AUTO_ATTACH="${ZELLIJ_AUTO_ATTACH:-false}"
export ZELLIJ_AUTO_EXIT="${ZELLIJ_AUTO_EXIT:-false}"
export ZELLIJ_DEFAULT_SESSION="${ZELLIJ_DEFAULT_SESSION:-localhost}"

#####################################################################################
## ZSH_PLUGINS
# `zsh-autosuggestions`' completion strategy toggles tty line-discipline while
# it probes completions. That can leave Kitty/Ghostty outside tmux with output
# no longer returning to column 0 after Enter, so only enable the completion
# strategy when we're already inside tmux.
if [[ -z "${ZSH_AUTOSUGGEST_STRATEGY+x}" ]]; then
    if [[ -n "$TMUX" ]]; then
        export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    else
        export ZSH_AUTOSUGGEST_STRATEGY=(history)
    fi
fi
if [[ -z "${ZSH_HIGHLIGHT_HIGHLIGHTERS+x}" ]]; then
    export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line regexp)
fi
export ZSH_TMUX_AUTOSTART="${ZSH_TMUX_AUTOSTART:-true}"
export ZSH_TMUX_CONFIG="${ZSH_TMUX_CONFIG:-$DOTFILES/config/tmux/tmux.conf}"
export ZSH_TMUX_DEFAULT_SESSION_NAME="${ZSH_TMUX_DEFAULT_SESSION_NAME:-localhost}"
export ZSH_TMUX_FIXTERM="${ZSH_TMUX_FIXTERM:-true}"

#####################################################################################
## Auto notify plugin
export AUTO_NOTIFY_BODY="${AUTO_NOTIFY_BODY:-Completed in %elapseds - Exit code %exit_code}"
export AUTO_NOTIFY_EXPIRE_TIME="${AUTO_NOTIFY_EXPIRE_TIME:-5000}"
if [[ -z "${AUTO_NOTIFY_IGNORE+x}" ]]; then
    export AUTO_NOTIFY_IGNORE=(vim ssh st fzf nvim mvim neovim zshrc zellij)
fi
export AUTO_NOTIFY_THRESHOLD="${AUTO_NOTIFY_THRESHOLD:-10000}"
export AUTO_NOTIFY_TITLE="${AUTO_NOTIFY_TITLE:-%command - Finished}"

#####################################################################################
## Cat + Bat + Less + Man
export BAT_PAGER="${BAT_PAGER:-less}"
export DELTA_PAGER="${DELTA_PAGER:-less -R}"
if [[ -z "${EDITOR+x}" ]] && (($+commands[nvim])); then
    export EDITOR="nvim"
fi
if [[ -z "${MANPAGER+x}" ]]; then
    if (($+commands[nvim])); then
        export MANPAGER="nvim +Man!"
    else
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi
fi
if [[ -z "${PAGER+x}" ]] && (($+commands[nvim])); then
    export PAGER="nvim"
fi

#####################################################################################
## other utils stuff
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export LESSOPEN="${LESSOPEN:-|$DOTFILES/bin/lessfilter.sh %s}"
export YSU_MESSAGE_POSITION="${YSU_MESSAGE_POSITION:-after}"
export MISE_NODE_DEFAULT_PACKAGES_FILE="${MISE_NODE_DEFAULT_PACKAGES_FILE:-$DOTFILES/config/mise/defaults/node}"

# Podman socket discovery is useful for Docker-compatible clients but is not
# needed for every shell. Defer the machine query until podman is first used.
typeset -g _DOTFILES_PODMAN_HOST_CHECKED=0
function _zsh_configure_podman_host() {
    emulate -L zsh
    ((_DOTFILES_PODMAN_HOST_CHECKED)) && return 0
    _DOTFILES_PODMAN_HOST_CHECKED=1
    [[ -n "${DOCKER_HOST:-}" ]] && return 0
    (($+commands[podman])) || return 0

    local podman_socket
    podman_socket="$(command podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null)" || return 0
    [[ -S "$podman_socket" ]] && export DOCKER_HOST="unix://$podman_socket"
}
if (($+commands[podman])); then
    function podman() {
        emulate -L zsh
        _zsh_configure_podman_host
        command podman "$@"
    }
fi

#####################################################################################
## ai
export ENABLE_LSP_TOOL="${ENABLE_LSP_TOOL:-1}"
export AI_CLI_NAME="${AI_CLI_NAME:-pi}"
export USE_BUILTIN_RIPGREP="${USE_BUILTIN_RIPGREP:-0}"
export PI_FFF_MODE="${PI_FFF_MODE:-override}"
export AI_CLI_MODEL="${AI_CLI_MODEL:-openai-codex/gpt-5.6-luna}"
export AI_COMMAND_PROMPT="${AI_COMMAND_PROMPT:-pi --model ${AI_CLI_MODEL}}"
export AI_QUERY_COMMAND="${AI_QUERY_COMMAND:-${AI_COMMAND_PROMPT} -p}"
if [[ -z "${AICOMMIT_EXCLUDES+x}" ]]; then
    export AICOMMIT_EXCLUDES=(package-lock.json pnpm-lock.yaml yarn.lock '*.lock')
fi
unset BUN_CONFIG_VERBOSE_FETCH
[[ -r "$DOTFILES/config/zsh/ls.sh" ]] && source "$DOTFILES/config/zsh/ls.sh"
