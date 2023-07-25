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
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

mkdir -p $HOME/.tmp

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom/plugins
git clone https://github.com/chrissicool/zsh-256color $ZSH_CUSTOM/zsh-256color
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/zsh-syntax-highlighting
git clone https://github.com/bigH/git-fuzzy.git $ZSH_CUSTOM/git-fuzzy
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
git clone https://github.com/Aloxaf/fzf-tab $ZSH_CUSTOM/fzf-tab
git clone https://github.com/wfxr/forgit $ZSH_CUSTOM/forgit
~/.fzf/install

curl https://get.volta.sh | bash

# Symlinks
ln -sf $HOME/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/zsh/vandalvnl.zsh-theme $HOME/.oh-my-zsh/themes/vandalvnl.zsh-theme
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
git config --global core.excludesFile '~/.gitignore'
git config --global init.defaultBranch main

# Node installs
volta install node@18.2.1
volta install yarn@1.22.1
npm i -g pnpm ts-node yarn add-gitignore neovim

## Python pip modules
pip install --user colour docker numpy pint inflect matplotlib fuzzywuzzy wheel meme

# Lunarvim
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
ln -sf $HOME/dotfiles/lvim/config.lua $HOME/.config/lvim/config.lua
