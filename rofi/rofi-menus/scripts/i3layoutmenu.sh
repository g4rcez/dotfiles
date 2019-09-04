#!/bin/bash

rofi_command="rofi -theme /home/garcez/dotfiles/rofi/rofi-menus/themes/i3layoutmenu.rasi"

### Options ###
stacked="S"
tabbed="T"
split="﬿"
# Variable passed to rofi
options="$stacked\n$tabbed\n$split"

chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 1)"
case $chosen in
    $stacked)
        i3-msg layout stacked
        ;;
    $tabbed)
        i3-msg layout tabbed
        ;;
    $split)
        i3-msg layout toggle split
        ;;
esac

