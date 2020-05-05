MENU="$(rofi -sep '|' -dmenu -i -p 'System' -location 0 -yoffset 20 -xoffset -0 -width 20 -hide-scrollbar -line-padding 4 -padding 20 -lines 4 <<< 'Lock|Logout|Reboot|Shutdown' -theme /home/g4rcez/dotfiles/rofi/rofi-menus/themes/appsmenu.rasi)"
case "$MENU" in
    *Lock) i3lock -c 000000 ;;
    *Logout) i3exit logout ;;
    *Reboot) reboot ;;
    *Shutdown) systemctl -i poweroff
esac
