brew install \
  bat bottom coreutils diff-so-fancy espanso lsd wezterm \
  fd ffmpeg findutils firefox gh git gnu-sed gnupg grep ipython \
  jq nuclei obsidian orbstack ripgrep rust starship telegram \
  visual-studio-code zellij zoxide starship nvim vivid tokei

if [[ "$(uname -s)" == "Darwin" ]]; then
  brew install --cask alt-tab
  brew install iterm2 karabiner-elements
  brew install koekeishiya/formulae/skhd
  skhd --start-service
fi


