gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 3
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
cat gnome.dconf | sed "s@__HOME__@${HOME}@g" > tmp
dconf load / < tmp
rm ./tmp
