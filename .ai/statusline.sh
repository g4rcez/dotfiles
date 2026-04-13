#!/usr/bin/env bash
# Claude Code statusline script
# Receives JSON on stdin or uses cache, outputs formatted text
# --compact flag: single line for tmux

COMPACT=false
if [[ "$1" == "--compact" ]]; then
  COMPACT=true
fi

# Cache for 10 seconds to avoid excessive processing
CACHE_FILE="/tmp/claude_statusline_cache"
if [[ ! -t 0 ]]; then
  json=$(cat)
  echo "$json" > "$CACHE_FILE"
elif [[ -f "$CACHE_FILE" ]]; then
  json=$(cat "$CACHE_FILE")
else
  exit 0
fi

# ANSI colors (actual escape chars)
GREEN=$'\033[32m'
GRAY=$'\033[90m'
RESET=$'\033[0m'

# dot_bar <pct> <filled_color>
dot_bar() {
  local pct=$1
  local filled_color=$2
  local filled=$(( (pct + 5) / 10 ))
  [[ $filled -gt 10 ]] && filled=10
  local empty=$(( 10 - filled ))
  local bar=""
  for ((i = 0; i < filled; i++)); do bar+="${filled_color}●${RESET}"; done
  for ((i = 0; i < empty; i++)); do bar+="${GRAY}○${RESET}"; done
  printf '%s' "$bar"
}

# Format epoch as "H:MMam/pm" (e.g. "7:00pm")
fmt_time() {
  local epoch=$1
  date -r "$epoch" "+%l:%M%p" | tr 'A-Z' 'a-z' | sed 's/^ //'
}

# Format epoch as "mon DD, H:MMam/pm" (e.g. "mar 10, 10:00am")
fmt_datetime() {
  local epoch=$1
  date -r "$epoch" "+%b %e, %l:%M%p" | tr 'A-Z' 'a-z' | sed 's/  */ /g; s/^ //'
}

# Fish-style shortened path: /Users/garcez/foo/bar/baz -> ~/f/b/baz
fish_dir() {
  local dir="${1/#"$HOME"/~}"
  IFS='/' read -ra parts <<< "$dir"
  local last=$(( ${#parts[@]} - 1 ))
  local result=""
  for ((i = 0; i <= last; i++)); do
    local part="${parts[i]}"
    if (( i == last )); then
      result+="$part"
    elif [[ "$part" == "~" || -z "$part" ]]; then
      result+="$part"
    else
      result+="${part:0:1}"
    fi
    (( i < last )) && result+="/"
  done
  echo "$result"
}

# Parse JSON fields
current_dir=$(echo "$json" | jq -r '.workspace.current_dir // ""')
model=$(echo "$json" | jq -r '.model.display_name // "Claude"')
context_pct=$(echo "$json" | jq -r '.context_window.used_percentage // 0 | floor')
five_hr_pct=$(echo "$json" | jq -r '.rate_limits.five_hour.used_percentage // 0 | floor')
five_hr_reset=$(echo "$json" | jq -r '.rate_limits.five_hour.resets_at // 0')
seven_day_pct=$(echo "$json" | jq -r '.rate_limits.seven_day.used_percentage // 0 | floor')
seven_day_reset=$(echo "$json" | jq -r '.rate_limits.seven_day.resets_at // 0')

# Strip "Claude " prefix
model="${model#Claude }"

# Project name (fish-style shortened path)
project=$(fish_dir "$current_dir")

# Worktree detection
worktree_json=$(echo "$json" | jq -r '.worktree // "null"')
is_worktree=false
if [[ "$worktree_json" != "null" ]]; then
  is_worktree=true
  branch=$(echo "$json" | jq -r '.worktree.branch // ""')
else
  git_dir=$(git -C "$current_dir" rev-parse --git-dir 2>/dev/null)
  git_common_dir=$(git -C "$current_dir" rev-parse --git-common-dir 2>/dev/null)
  if [[ -n "$git_dir" && "$git_dir" != "$git_common_dir" ]]; then
    is_worktree=true
  fi
  branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
fi

# Dirty check: append * to branch if working tree is dirty
dirty=$(git -C "$current_dir" status --porcelain 2>/dev/null)
[[ -n "$dirty" ]] && branch="${branch}*"

if $COMPACT; then
  echo "${model} ${context_pct}%"
else
  # Line 1: model | context% | project (branch) [worktree icon]
  if $is_worktree; then
    worktree_suffix=" ${GREEN}${RESET}"
  else
    worktree_suffix=""
  fi
  bar_current=$(dot_bar "$five_hr_pct" "$RESET")
  reset_current=$(fmt_time "$five_hr_reset")
  bar_weekly=$(dot_bar "$seven_day_pct" "$RESET")
  reset_weekly=$(fmt_datetime "$seven_day_reset")

  echo "${model} ${GRAY}|${RESET} ${context_pct}% ${GRAY}|${RESET} ${project} - ${branch}${worktree_suffix} ${GRAY}|${RESET} current ${bar_current} ${five_hr_pct}% ${GRAY}↻ ${reset_current}${RESET} ${GRAY}|${RESET} weekly ${bar_weekly} ${seven_day_pct}% ${GRAY}↻ ${reset_weekly}${RESET}"
fi
