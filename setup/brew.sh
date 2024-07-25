brew install \
    bat coreutils git-delta espanso lsd wezterm \
    fd ffmpeg findutils gh git gnupg grep ipython \
    jq obsidian orbstack ripgrep rust starship telegram \
    visual-studio-code zoxide starship nvim vivid tokei \
    gitleaks docker docker-compose colima fx

if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install --cask karabiner-elements alt-tab gnu-sed
fi
