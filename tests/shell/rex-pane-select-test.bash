#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$repo_root/bin/rex-pane-select"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

# Digit 1 in a 6x5 area: one font pixel is 2 columns by 1 row, blue is 7aa2f7 = 122;162;247.
actual="$(bash "$script" render 1 7aa2f7 6 5)"
expected=$'\033[1;1H  \033[48;2;122;162;247m  \033[0m  '
expected+=$'\033[2;1H\033[48;2;122;162;247m  \033[0m\033[48;2;122;162;247m  \033[0m  '
expected+=$'\033[3;1H  \033[48;2;122;162;247m  \033[0m  '
expected+=$'\033[4;1H  \033[48;2;122;162;247m  \033[0m  '
expected+=$'\033[5;1H\033[48;2;122;162;247m  \033[0m\033[48;2;122;162;247m  \033[0m\033[48;2;122;162;247m  \033[0m'
[[ "$actual" == "$expected" ]] || fail "digit 1 at 6x5 rendered differently"

# A bigger area doubles each pixel in both directions and centers the digit: 12x10 gives scale 2, 4 columns per pixel.
actual="$(bash "$script" render 1 7aa2f7 12 10)"
[[ "$actual" == $'\033[1;1H'* ]] || fail "digit 1 at 12x10 did not start at row 1, column 1"
[[ "$actual" == *$'\033[2;1H'* ]] || fail "digit 1 at 12x10 did not repeat each pixel row twice"

# Only 1 to 9 are digits.
if bash "$script" render 0 7aa2f7 6 5 >/dev/null 2>&1; then
    fail "digit 0 must be rejected"
fi

printf 'rex-pane-select tests passed\n'
