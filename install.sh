#
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║ ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝ Dotfiles by: @vandalvnl git clone https://github.com/g4rcez/dotfiles $HOME/dotfiles
cd $HOME/dotfiles
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Manjaro install
mkdir -p $HOME/.tmp
sudo pacman-mirrors --fasttrack
sudo pacman -S base-devel bat zoxide flameshot vim neovim docker python-pip jq docker-compose screenkey python-pip yay yq exa gnome gnome-shell xclip gnome-shell-extensions muparser kitty go cargo telegram-desktop python-pip
yay -S albert visual-studio-code-bin github-cli google-chrome albert dotnet-runtime dotnet-sdk

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
git clone https://github.com/chrissicool/zsh-256color $ZSH_CUSTOM/plugins/zsh-256color
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone git@github.com:grigorii-zander/zsh-npm-scripts-autocomplete.git ~/.oh-my-zsh/custom/plugins/zsh-npm-scripts-autocomplete
git clone https://github.com/popstas/zsh-command-time.git ~/.oh-my-zsh/custom/plugins/command-time

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Misc Stuff
cp curlrc ~/.curlrc

curl https://get.volta.sh | bash

# Symlinks
ln -sf $HOME/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/zsh/vandalvnl.zsh-theme $HOME/.oh-my-zsh/themes/vandalvnl.zsh-theme
ln -sf $HOME/dotfiles/idea/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/global_gitignore $HOME/.gitignore
ln -sf $HOME/dotfiles/vim/vimrc $HOME/.vimrc
ln -sf $HOME/dotfiles/.config/wezterm/main.lua $HOME/.wezterm.lua
ln -sf $HOME/dotfiles/.config/kitty $HOME/.config/kitty

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
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh)
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh)
ln -sf $HOME/dotfiles/lvim/config.lua $HOME/.config/lvim/config.lua

# My keyboard
ln -sf $HOME/dotfiles/dygma $HOME/Raise

# Tools dir
mkdir -p $HOME/tools
