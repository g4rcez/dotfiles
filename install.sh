#
# ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
# ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
# ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
# ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
# ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
# ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
# Dotfiles by: @vandalvnl
# ToDo:
## install rofi
## install polybar
## configure KDE shortcuts
## install vscode theme and plugins|shortcuts

git clone https://github.com/g4rcez/dotfiles $HOME/dotfiles
cd $HOME/dotfiles
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
git clone https://github.com/chrissicool/zsh-256color $ZSH_CUSTOM/plugins/zsh-256color
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting


# Misc Stuff
cp curlrc ~/.curlrc

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

ln -sf $HOME/dotfiles/zsh/zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/zsh/vandalvnl.zsh-theme $HOME/.oh-my-zsh/themes/vandalvnl.zsh-theme
