brew install \
    bat coreutils git-delta espanso lsd wezterm alacritty \
    fd ffmpeg findutils gh git gnu-sed gnupg grep ipython \
    jq obsidian orbstack ripgrep rust starship telegram \
    visual-studio-code zoxide starship nvim vivid tokei

if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install --cask karabiner-elements alt-tab
fi
