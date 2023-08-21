#
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
# Dotfiles by: @g4rcez
# git clone https://github.com/g4rcez/dotfiles $HOME/dotfiles
# cd $HOME/dotfiles

mkdir -p $HOME/.tmp
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

curl https://get.volta.sh | bash

# Symlinks
ln -sf $HOME/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/config/fd/.fdignore $HOME/.fdignore
ln -sf $HOME/dotfiles/idea/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/git/global_gitignore $HOME/.gitignore
ln -sf $HOME/dotfiles/vim/vimrc $HOME/.vimrc
ln -sf $HOME/dotfiles/config/wezterm/main.lua $HOME/.wezterm.lua
ln -sf $HOME/dotfiles/config/kitty $HOME/.config/kitty
ln -sf $HOME/dotfiles/git/gitconfig $HOME/.gitconfig
ln -sf $HOME/dotfiles/config/starship.toml $HOME/.config/starship.toml

# My keyboard
ln -sf $HOME/dotfiles/dygma $HOME/Raise

# Tools dir
mkdir -p $HOME/tools

# Git
git config --global core.excludesFile "$HOME/.gitignore"
git config --global init.defaultBranch main

# Node installs
volta install node@18.2.1
volta install yarn@1.22.1
npm i -g pnpm ts-node yarn neovim

## Python pip modules
pip install --user colour docker numpy pint inflect matplotlib fuzzywuzzy wheel meme

# Lunarvim
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
ln -sf "$HOME/dotfiles/lvim/config.lua" "$HOME/.config/lvim/config.lua"
