#!/bin/bash
CURRENT=$(pkexec xfpm-power-backlight-helper --get-brightness)
if [[ "$1" == "sum" ]]; then
	if [[ $CURRENT -lt 1500 ]]; then
		pkexec xfpm-power-backlight-helper --set-brightness $(($CURRENT + 250))
	fi
else
	pkexec xfpm-power-backlight-helper --set-brightness $(($CURRENT - 250))
fi

