#!/usr/bin/env bash

mime=$(file -bL --mime-type "$1")
category=${mime%%/*}
kind=${mime##*/}
regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'

TARGET_PATH="${1/\~/$HOME}"

if [ -d "$TARGET_PATH" ]; then
    echo "$TARGET_PATH"
    lsd --git --color=always "$TARGET_PATH"
elif [ "$category" = "image" ]; then
    echo "$PWD/$1"
    chafa -f sixel -s 40 "$TARGET_PATH"
    exiftool "$TARGET_PATH"
elif [ "$kind" = "vnd.openxmlformats-officedocument.spreadsheetml.sheet" ] ||
    [ "$kind" = "vnd.ms-excel" ]; then
    in2csv "$TARGET_PATH" | xsv table | bat --theme OneHalfDark --color=always -ltsv
elif [ "$category" = "text" ]; then
    bat --theme OneHalfDark --color=always "$TARGET_PATH"
elif [ "$category" = "application/pdf" ]; then
    bat --theme OneHalfDark --color=always "$TARGET_PATH"
elif [[ ${1} =~ $regex ]]; then
    echo "$TARGET_PATH"
else
    bat --theme OneHalfDark --color=always "$TARGET_PATH" &>/dev/null
fi
