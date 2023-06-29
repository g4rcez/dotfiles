#!/usr/bin/env bash
mime=$(file -bL --mime-type "$1")
category=${mime%%/*}
kind=${mime##*/}
if [ -d "$1" ]; then
	exa --git -hl --color=always --icons "$1"
elif [ "$category" = image ]; then
	echo "$PWD/$1"
	exiftool "$1"
elif [ "$kind" = vnd.openxmlformats-officedocument.spreadsheetml.sheet ] || \
	[ "$kind" = vnd.ms-excel ]; then
	in2csv "$1" | xsv table | bat -ltsv --color=always
elif [ "$category" = text ]; then
	bat --color=always "$1"
fi
