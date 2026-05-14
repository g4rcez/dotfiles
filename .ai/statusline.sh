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

# Parse all JSON fields in one jq call (tab-separated; none of these values contain tabs)
IFS=$'\t' read -r current_dir model context_pct five_hr_pct five_hr_reset seven_day_pct seven_day_reset wt_branch < <(
  jq -r '[
    (.workspace.current_dir // ""),
    (.model.display_name // "Claude"),
    ((.context_window.used_percentage // 0) | floor | tostring),
    ((.rate_limits.five_hour.used_percentage // 0) | floor | tostring),
    ((.rate_limits.five_hour.resets_at // 0) | tostring),
    ((.rate_limits.seven_day.used_percentage // 0) | floor | tostring),
    ((.rate_limits.seven_day.resets_at // 0) | tostring),
    (.worktree.branch // "")
  ] | join("\t")' <<< "$json"
)

model="${model#Claude }"
project=$(fish_dir "$current_dir")

# Git state — cache for 5 s to avoid 4 forks on every status-bar render
_ck=$(printf '%s' "$current_dir" | shasum 2>/dev/null | cut -c1-16 \
      || printf '%s' "$current_dir" | md5 -q 2>/dev/null \
      || printf '%s' "$current_dir" | md5sum 2>/dev/null | cut -c1-16)
_cf="/tmp/.claude_sl_git_${_ck}"
_use_cache=0
if [[ -f "$_cf" ]]; then
  _mtime=$(stat -f '%m' "$_cf" 2>/dev/null || stat -c '%Y' "$_cf" 2>/dev/null || echo 0)
  _age=$(( $(date +%s) - _mtime ))
  (( _age < 5 )) && _use_cache=1
fi

is_worktree=false
if (( _use_cache )); then
  IFS=$'\t' read -r _gd _gcd branch _dflag < "$_cf"
else
  _gd=$(git -C "$current_dir" rev-parse --git-dir 2>/dev/null || echo "")
  _gcd=$(git -C "$current_dir" rev-parse --git-common-dir 2>/dev/null || echo "")
  branch=$(git -C "$current_dir" branch --show-current 2>/dev/null || echo "")
  _dirty=$(git -C "$current_dir" status --porcelain 2>/dev/null || echo "")
  _dflag="0"; [[ -n "$_dirty" ]] && _dflag="1"
  printf '%s\t%s\t%s\t%s\n' "$_gd" "$_gcd" "$branch" "$_dflag" > "$_cf"
fi

# Worktree: prefer branch from JSON (already resolved); fall back to git detection
if [[ -n "$wt_branch" ]]; then
  is_worktree=true
  branch="$wt_branch"
elif [[ -n "$_gd" && "$_gd" != "$_gcd" ]]; then
  is_worktree=true
fi
[[ "${_dflag:-0}" == "1" ]] && branch="${branch}*"

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
