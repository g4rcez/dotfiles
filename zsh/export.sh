#!/bin/bash
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESSOPEN='|~/dotfiles/bin/lessfilter.sh %s'

export ARCHFLAGS="-arch x86_64"
export BROWSER="google-chrome"
export DOTNET_ROOT="$HOME/.dotnet"
export GPG_TTY="$(tty)"
export MANPATH="/usr/local/man:$MANPATH"
export MANWIDTH=999

############################################## Node ##########################################################
export PNPM_HOME="$HOME/.local/share/pnpm"
export VOLTA_HOME="$HOME/.volta"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/JetBrains/scripts"
# bun completions
BUN_DIR="$HOME/.bun/_bun"
[ -s "$BUN_DIR" ] && source "$BUN_DIR"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/share:$HOME/.local/bin:$HOME/.local/share/bin:$PATH"
export PATH="$HOME/tools/google-cloud-sdk/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
export PATH="$PATH:$HOME/dotfiles/bin"
export PATH="$PATH:$HOME/tools"
export PATH="$PATH:/snap/bin"

if [ -x "$(command -v nvim)" ]; then
  export EDITOR="nvim"
  export MANPAGER="nvim +Man!"
  export PAGER="nvim"
else
  export EDITOR="vim"
fi
############################################## Plugins Config ##########################################################
export YSU_MESSAGE_POSITION="after"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
