#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

transcript=$(echo "$input" | jq -r '.transcript_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

[[ -z "$transcript" || -z "$session_id" ]] && exit 0
[[ ! -f "$transcript" ]] && exit 0

plans_dir="$PWD/.ai/plans"
mkdir -p "$plans_dir"

session_short="${session_id:0:8}"

extract_text() {
  local role="$1" pos="$2"
  jq -rs "
    [.[] | select(.type == \"$role\") |
      .message.content |
      if type == \"array\" then
        [.[] | select(type == \"object\" and .type == \"text\") | .text] | join(\"\")
      elif type == \"string\" then .
      else \"\"
      end |
      select(length > 0) |
      select(test(\"^\\\\[.*\\\\]$\") | not)
    ] | $pos // \"\"
  " "$transcript"
}

first_user=$(extract_text "user" "first")
first_asst=$(extract_text "assistant" "first")
last_asst=$(extract_text "assistant" "last")

[[ -z "$first_user" ]] && exit 0

title_line=$(echo "$first_user" | head -1 | cut -c1-80)
slug=$(echo "$title_line" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs 'a-z0-9' '-' \
  | sed 's/-\+/-/g;s/^-//;s/-$//' \
  | cut -c1-50)
[[ -z "$slug" ]] && slug="session"

existing=$(find "$plans_dir" -maxdepth 1 -name "*_${session_short}_*.md" -type f 2>/dev/null | sort | head -1)

if [[ -n "$existing" ]]; then
  outfile="$existing"
else
  date_prefix=$(date +"%Y%m%d")
  outfile="$plans_dir/${date_prefix}_${session_short}_${slug}.md"
fi

{
  printf '# %s\n\n' "$title_line"
  printf '_Session: %s | Saved: %s_\n\n' "$session_id" "$(date '+%Y-%m-%d %H:%M:%S')"
  printf '## Prompt\n\n%s\n\n' "$first_user"
  printf '## Plan\n\n%s\n\n' "$first_asst"
  if [[ "$last_asst" != "$first_asst" ]]; then
    printf '## Resolution\n\n%s\n' "$last_asst"
  fi
} > "$outfile"
