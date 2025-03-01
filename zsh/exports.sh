#####################################################################################
## Important exports
export LISTMAX=10000
export DOTFILES="$HOME/dotfiles"
export TS_SCRIPTS="$HOME/dotfiles/bin"
export ZSH="$HOME/.zsh/plugins/ohmyzsh/ohmyzsh"
export PLUGINS_DIR="$HOME/.zsh/plugins"
export SNAP_DIR="$PLUGINS_DIR/znap"
export BROWSER="google-chrome"
export GPG_TTY="$(tty)"
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
if [ -x "$(command -v colima)" ]; then
    export DOCKER_HOST="unix://$HOME/.colima/docker.sock"
fi

#####################################################################################
## ZELLIJ_CONFIG
export ZELLIJ_AUTO_ATTACH=true
export ZELLIJ_AUTO_EXIT=false
export ZELLIJ_DEFAULT_SESSION="localhost"

#####################################################################################
## ZSH_PLUGINS
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
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
if [ -x "$(command -v nvim)" ]; then
    export EDITOR="nvim"
    export MANPAGER="nvim +Man!"
    export PAGER="nvim"
fi

#####################################################################################
## other utils stuff
export BUN_INSTALL="$HOME/.bun"
export LESSOPEN='|~/dotfiles/bin/lessfilter.sh %s'
export PNPM_HOME="$HOME/.local/share/pnpm"
export YSU_MESSAGE_POSITION="after"
export MISE_NODE_DEFAULT_PACKAGES_FILE="$DOTFILES/config/mise/defaults/node"
source "$DOTFILES/zsh/ls.sh"

