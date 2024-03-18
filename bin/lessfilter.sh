#!/usr/bin/env bash

mime=$(file -bL --mime-type "$1")
category=${mime%%/*}
kind=${mime##*/}

if [ -d "$1" ]; then
  lsd --git -hl --color=always --tree
elif [ "$category" = "image" ]; then
  echo "$PWD/$1"
  exiftool "$1"
elif [ "$kind" = "vnd.openxmlformats-officedocument.spreadsheetml.sheet" ] ||
  [ "$kind" = "vnd.ms-excel" ]; then
  in2csv "$1" | xsv table | bat --theme OneHalfDark --color=always -ltsv
elif [ "$category" = "text" ]; then
  bat --theme OneHalfDark --color=always "$1"
elif [ "$category" = "application/pdf" ]; then
  bat --theme OneHalfDark --color=always "$1"
else
  bat --theme OneHalfDark --color=always "$1"
fi
