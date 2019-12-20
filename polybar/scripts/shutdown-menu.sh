MENU="$(rofi -sep '|' -dmenu -i -p 'System' -location 0 -yoffset 20 -xoffset -0 -width 20 -hide-scrollbar -line-padding 4 -padding 20 -lines 4 <<< ' Lock| Logout| Reboot| Shutdown' -theme /home/garcez/dotfiles/rofi/rofi-menus/themes/appsmenu.rasi)"
case "$MENU" in
    *Lock) betterlockscreen -l dimblur -t Dica: "Não use" ;;
    *Logout) i3exit logout, mode "default" ;;
    *Reboot) reboot ;;
    *Shutdown) systemctl -i poweroff
esac
