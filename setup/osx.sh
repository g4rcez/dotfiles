# "Disable press-and-hold for keys in favor of key repeat"
defaults write -g ApplePressAndHoldEnabled -bool false

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

# Set a really fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 1

# Set the Finder prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# "Set a shorter Delay until key repeat"
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# "Enable tap to click (Trackpad)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# "Enable Safari’s debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# "Show Status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "
