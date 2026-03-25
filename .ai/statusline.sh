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
  # JSON on stdin
  json=$(cat)
  echo "$json" > "$CACHE_FILE"
elif [[ -f "$CACHE_FILE" ]]; then
  # Use cache if stdin is terminal (like when tmux calls it)
  json=$(cat "$CACHE_FILE")
else
  # No data
  exit 0
fi

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
  icon=""
  branch=$(echo "$json" | jq -r '.worktree.branch // ""')
else
  icon=""
  branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
fi

# PR number
pr=$(gh pr view --json number -q .number "$current_dir" 2>/dev/null)

# Model: strip "Claude " prefix
model="${model#Claude }"

# Cost: format as $X.XX
cost_fmt=$(printf '$%.2f' "$cost")

# Context%
ctx_fmt="${context_pct}%"

if $COMPACT; then
  # Single line for tmux status bar
  # We skip the dir and branch to keep it short in tmux
  # Format: "Model $Cost Ctx%"
  echo " $model $cost_fmt $ctx_fmt"
else
  # Line 1
  line1="$dir $icon $branch"
  if [[ -n "$pr" ]]; then
    line1="$line1 - PR: #$pr"
  fi
  # Line 2
  line2="$model - $cost_fmt - $ctx_fmt"
  echo "$line1"
  echo "$line2"
fi
