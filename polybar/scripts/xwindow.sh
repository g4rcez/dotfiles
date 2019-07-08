PROGRAM="$(cat /proc/$(xdotool getwindowpid $(xdotool getwindowfocus))/comm | tr -d '\n' 2>/dev/null)"
NAME="$(xdotool getwindowfocus getwindowname 2>/dev/null)"

case $PROGRAM in
	code-insiders) echo -e "\uf667 VsCode - $NAME" && break ;;
	termite) echo -e "\ue795 Terminal - $NAME" && break ;;
	chromium) echo -e "\uf268 $NAME" && break ;;
	telegram-deskto) echo -e "\ue217 $NAME" && break ;;
	spotify) echo -e "\uf1bc $NAME" && break ;;
	thunar) echo -e "\uf07c $NAME" && break ;;
	*) echo "$PROGRAM - $NAME" | sed 's/^./\U&/g' | sed 's/window ?.*/Hello Sir/g' ;;
esac