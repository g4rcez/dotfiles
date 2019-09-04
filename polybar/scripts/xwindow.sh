PROGRAM="$(cat /proc/$(xdotool getwindowpid $(xdotool getwindowfocus))/comm | tr -d '\n' 2>/dev/null)"
NAME="$(xdotool getwindowfocus getwindowname 2>/dev/null | cut -c1-80)"

case $PROGRAM in
	code) echo -e "﬏ VsCode - $NAME" && break ;;
	kitty) echo -e "\ue795 Terminal" && break ;;
	google-chrome) echo -e "\uf268 $NAME" && break ;;
	telegram-deskto) echo -e "\ue217 $NAME" && break ;;
	spotify) echo -e "\uf1bc $NAME" && break ;;
	thunar) echo -e " $NAME" && break ;;
	*) echo "$PROGRAM - $NAME" | sed 's/^./\U&/g' | sed 's/window ?.*/Hello Sir/g' ;;
esac