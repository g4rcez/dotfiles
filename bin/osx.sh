/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

defaults write -g ApplePressAndHoldEnabled -bool false
ln -sf $HOME/dotfiles/espanso "$HOME/Library/Application\ Support/espanso/match/base.yml"

# Show the ~/Library folder.
chflags nohidden ~/Library

# Disable press-and-hold for keys in favor of key repeat.
sudo defaults write -g ApplePressAndHoldEnabled -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Increase sound quality for Bluetooth headphones/headsets
sudo defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
sudo defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Enable Firewall Service
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Enable Stealth Mode (Prevent others from discovering your Mac)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on