#!/usr/bin/env bash
# Claude Code statusline script
# Receives JSON on stdin, outputs 2 lines of formatted text

json=$(cat)

# Fish-style directory shortening: shorten all components except last to first char
fish_dir() {
  local dir="$1"
  # Replace $HOME with ~
  dir="${dir/#$HOME/~}"
  # Split by / and shorten all but last component
  IFS='/' read -ra parts <<< "$dir"
  local result=""
  local count="${#parts[@]}"
  for ((i = 0; i < count; i++)); do
    if [[ -z "${parts[$i]}" ]]; then
      result+="/"
    elif ((i == count - 1)); then
      result+="${parts[$i]}"
    else
      result+="${parts[$i]:0:1}/"
    fi
  done
  echo "$result"
}

current_dir=$(echo "$json" | jq -r '.workspace.current_dir // ""')
model=$(echo "$json" | jq -r '.model.display_name // "Claude"')
cost=$(echo "$json" | jq -r '.cost.total_cost_usd // 0')
context_pct=$(echo "$json" | jq -r '.context_window.used_percentage // 0')
worktree=$(echo "$json" | jq -r '.worktree // "null"')

# Fish-style dir
dir=$(fish_dir "$current_dir")

# Worktree icon and branch
if [[ "$worktree" != "null" ]]; then
  icon=" "
  branch=$(echo "$json" | jq -r '.worktree.branch // ""')
else
  icon=" "
  branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
fi

# PR number
pr=$(gh pr view --json number -q .number 2>/dev/null)

# Line 1
line1="$dir $icon $branch"
if [[ -n "$pr" ]]; then
  line1="$line1 - PR: #$pr"
fi

# Model: strip "Claude " prefix
model="${model#Claude }"

# Cost: format as $X.XX
cost_fmt=$(printf '$%.2f' "$cost")

# Context%
ctx_fmt="${context_pct}%"

# Line 2
line2="$model - $cost_fmt - $ctx_fmt"

echo "$line1"
echo "$line2"
