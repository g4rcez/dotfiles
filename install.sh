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

##############################################################
#
#   Before install, you need to execute the install script of
#   `oh-my-zsh`. URL:
#   
#
##############################################################

git clone https://github.com/vandalvnl/dotfiles $HOME/dotfiles
cd $HOME/dotfiles

$ZSH_PATH=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
$ZSHRC=
# ZSH Config
git clone https://github.com/chrissicool/zsh-256color $ZSH_PATH/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PATH/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PATH/plugins/zsh-syntax-highlighting

# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
echo ". $HOME/.asdf/asdf.sh" > "$HOME/.zshrc"
echo ". $HOME/.asdf/completions/asdf.bash" > $HOME/.zshrc
asdf update --head
# asdf NodeJS plugin
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
NODE_LATEST_VERSION="$(asdf list-all nodejs | tail -n1)"
asdf install nodejs $NODE_LATEST_VERSION
asdf global nodejs $NODE_LATEST_VERSION

# npm install
npm i -g npm create-react-app create-react-library typescript expo-cli ts-node serve http-server yarn

# SDKMAN
curl -s "https://get.sdkman.io" | zsh
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java
sdk install maven
sdk install gradle
sdk install sbt
sdk install scala

# Misc Stuff
cp curlrc ~/.curlrc

# Install vscode extensions

cat $HOME/dotfiles/vscode/extensions.list | sed 's/.*/code --install-extension &/g' | bash