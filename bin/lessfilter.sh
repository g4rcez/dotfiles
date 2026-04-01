#!/usr/bin/env bash

# FILENAME:LINENO parsing (for grep/rg output fed into fzf)
file=${1/#\~\//$HOME/}
center=0
if [[ ! -r $file ]]; then
    if [[ $file =~ ^(.+):([0-9]+)[[:space:]]*$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
        file=${BASH_REMATCH[1]}
        center=${BASH_REMATCH[2]}
    elif [[ $file =~ ^(.+):([0-9]+):[0-9]+[[:space:]]*$ ]] && [[ -r ${BASH_REMATCH[1]} ]]; then
        file=${BASH_REMATCH[1]}
        center=${BASH_REMATCH[2]}
    fi
fi

mime=$(file -bL --mime-type -- "$file")
category=${mime%%/*}
kind=${mime##*/}

bat_opts=(--style=plain --theme=OneHalfDark --color=always --pager=never)
[[ $center -gt 0 ]] && bat_opts+=(--highlight-line="$center")

# Directory
if [[ -d $file ]]; then
    echo "$file"
    lsd --git --color=always "$file"
    exit
fi

# Image
if [[ $category == image ]]; then
    if [[ -n $FZF_PREVIEW_COLUMNS ]]; then
        dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
        # Avoid Sixel scrolling issue at bottom of screen
        if ! [[ $KITTY_WINDOW_ID ]] && ((FZF_PREVIEW_TOP + FZF_PREVIEW_LINES == $(stty size < /dev/tty | awk '{print $1}'))); then
            dim=${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES - 1))
        fi
        if { [[ $KITTY_WINDOW_ID ]] || [[ $GHOSTTY_RESOURCES_DIR ]]; } && command -v kitten &>/dev/null; then
            kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="${dim}@0x0" "$file" | sed '$d' | sed $'$s/$/\e[m/'
        elif command -v chafa &>/dev/null; then
            chafa -s "$dim" "$file"
            echo
        fi
    else
        chafa --passthrough auto --size "${COLUMNS:-80}" "$file"
    fi
    exiftool "$file"
    exit
fi

# Spreadsheet (xlsx, xls)
if [[ $kind == vnd.openxmlformats-officedocument.spreadsheetml.sheet || $kind == vnd.ms-excel ]]; then
    in2csv "$file" | xsv table | bat "${bat_opts[@]}" -ltsv
    exit
fi

# PDF
if [[ $kind == pdf ]]; then
    if command -v pdftotext &>/dev/null; then
        pdftotext -l 10 -nopgbrk -q -- "$file" -
    else
        bat "${bat_opts[@]}" -- "$file"
    fi
    exit
fi

# Text / source (includes application/json, application/javascript, etc.)
if [[ $category == text ]] || [[ $kind == json || $kind == javascript || $kind == x-ndjson || $kind == xml || $kind == yaml ]]; then
    bat "${bat_opts[@]}" -- "$file"
    exit
fi

# Binary or unknown
if [[ $mime =~ =binary ]]; then
    file -b -- "$file"
    exit
fi

# Fallback: attempt bat, otherwise describe the file
bat "${bat_opts[@]}" -- "$file" 2>/dev/null || file -b -- "$file"
