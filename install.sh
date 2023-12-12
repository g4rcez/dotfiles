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
mkdir -p $HOME/tools $HOME/.tmp
########################################################################################################################
##### fzf
if [[ -f "$(command -v fzf)" ]];then
    echo "fzf installed"
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

########################################################################################################################
##### brew
if [[ -f "$(command -v brew)" ]];then
    echo "brew installed"
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    /bin/bash $HOME/dotfiles/setup/brew.sh
fi

########################################################################################################################
##### node config
curl https://get.volta.sh | bash
volta install node@latest
volta install yarn@1.22.1
npm i -g pnpm ts-node yarn neovim

########################################################################################################################
##### python modules
pip3 install --user colour docker numpy pint inflect matplotlib fuzzywuzzy wheel meme

########################################################################################################################
##### lazyvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
ln -sf $HOME/dotfiles/nvim/ $HOME/.config/nvim/
ln -sf $HOME/dotfiles/vim/vimrc $HOME/.vimrc

########################################################################################################################
##### symlinks
# ln -sf $HOME/dotfiles/config/kitty $HOME/.config/kitty
# ln -sf $HOME/dotfiles/config/wezterm/main.lua $HOME/.wezterm.lua
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
