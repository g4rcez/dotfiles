export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

export ARCHFLAGS="-arch x86_64"
export BROWSER="google-chrome"
export DOTNET_ROOT=$HOME/.dotnet
export GPG_TTY=$(tty)
export MANPATH="/usr/local/man:$MANPATH"
export MANWIDTH=999
export PNPM_HOME="$HOME/.local/share/pnpm"
export VOLTA_HOME="$HOME/.volta"

export PATH="$HOME/.local/share:$HOME/.local/bin:$HOME/.local/share/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/tools/google-cloud-sdk/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
export PATH="$PATH:$HOME/dotfiles/scripts"
export PATH="$PATH:$HOME/tools"
export PATH="$PATH:/snap/bin"
export PATH="$PNPM_HOME:$PATH"
export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export python="/usr/bin/python3"

if [ -x "$(command -v lvim)" ]; then
  export EDITOR="lvim"
  export MANPAGER='lvim +Man!'
else
  export EDITOR="vim"
fi
