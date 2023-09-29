#!/bin/bash
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
mkdir -p $HOME/.tmp
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1;
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
curl https://get.volta.sh | bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file "$HOME/dotfiles/config/Brewfile"
~/.fzf/install
############################################# Node installs ############################################################
volta install node@18.2.1
volta install yarn@1.22.1
npm i -g pnpm ts-node yarn neovim

############################################ Python modules ############################################################
pip install --user colour docker numpy pint inflect matplotlib fuzzywuzzy wheel meme

############################################ Symlinks ##################################################################
ln -sf $HOME/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/config/fd/.fdignore $HOME/.fdignore
ln -sf $HOME/dotfiles/idea/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/git/global_gitignore $HOME/.gitignore
ln -sf $HOME/dotfiles/vim/vimrc $HOME/.vimrc
ln -sf $HOME/dotfiles/config/wezterm/main.lua $HOME/.wezterm.lua
ln -sf $HOME/dotfiles/config/kitty $HOME/.config/kitty
ln -sf $HOME/dotfiles/git/gitconfig $HOME/.gitconfig
ln -sf $HOME/dotfiles/config/starship.toml $HOME/.config/starship.toml
ln -sf $HOME/dotfiles/nvim/ $HOME/.config/nvim/
ln -sf $HOME/dotfiles/nvim/ $HOME/.config/nvim/lua/custom
ln -sf $HOME/dotfiles/dygma $HOME/Raise
############################################### My keyboard ############################################################
mkdir -p $HOME/tools
git config --global core.excludesFile "$HOME/.gitignore"
git config --global init.defaultBranch main
