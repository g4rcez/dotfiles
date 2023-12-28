if [[ "$(uname -s)" == "Darwin" ]]; then
  brew install --cask alt-tab
  brew install iterm2 karabiner-elements
fi

brew install bat bottom coreutils diff-so-fancy espanso lsd \
  fd ffmpeg findutils firefox fish gh git gnu-sed gnupg grep httpie ipython \
  jq nuclei nvim obsidian orbstack ripgrep rust starship telegram visual-studio-code zellij zoxide starship nvim
