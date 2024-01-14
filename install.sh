#!/bin/bash
########################################################################################################################
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
########################################################################################################################
set -xe
mkdir -p $HOME/tools $HOME/.tmp;

function checkcommand () {
  if [[ -f "$(command -v $1)" ]]; then
    echo "fzf installed"
  else
    $2
  fi
}
########################################################################################################################
##### fzf
function installfzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
}
checkcommand "fzf" installfzf
########################################################################################################################
##### brew
function installbrew() {
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  bash $HOME/dotfiles/setup/brew.sh
}
checkcommand "brew" installbrew
########################################################################################################################
##### node config
function installvolta() {
  curl https://get.volta.sh | bash
  volta install node@latest
  volta install yarn@1.22.1
  npm i -g pnpm ts-node yarn neovim
}
checkcommand "volta" installvolta
########################################################################################################################
##### python modules
pip3 install --user colour docker numpy pint inflect matplotlib fuzzywuzzy wheel meme

########################################################################################################################
##### lazyvim
ln -sf $HOME/dotfiles/nvim/ $HOME/.config/nvim/

########################################################################################################################
##### symlinks
# ln -sf $HOME/dotfiles/config/kitty $HOME/.config/kitty
ln -sf $HOME/dotfiles/config/wezterm/wezterm.lua $HOME/.wezterm.lua
ln -sf $HOME/dotfiles/config/fd/.fdignore $HOME/.fdignore
ln -sf $HOME/dotfiles/config/starship.toml $HOME/.config/starship.toml
ln -sf $HOME/dotfiles/idea/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/dygma $HOME/Raise

########################################################################################################################
##### gitconfig
ln -sf $HOME/dotfiles/git/gitconfig $HOME/.gitconfig
ln -sf $HOME/dotfiles/git/global_gitignore $HOME/.gitignore
git config --global core.excludesFile "$HOME/.gitignore"
git config --global init.defaultBranch main

#########################################################################################################################
###### misc

## atuin history
function installatuin() {
  bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
}
checkcommand "atuin" installatuin

