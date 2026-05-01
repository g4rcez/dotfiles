#!/usr/bin/env zsh
set -euo pipefail

input=$(cat)

transcript=$(echo "$input" | jq -r '.transcript_path // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

[[ -z "$transcript" || -z "$session_id" ]] && exit 0
[[ ! -f "$transcript" ]] && exit 0

plans_dir="$PWD/.ai/plans"
mkdir -p "$plans_dir"

# Track which message indexes were already saved in this session
saved_index="$plans_dir/.session-${session_id}"
touch "$saved_index"

jq -c 'to_entries[] | select(.value.role == "assistant") | {
  idx: .key,
  text: (
    .value.content
    | if type == "array" then
        map(select(type == "object" and .type == "text") | .text) | join("")
      elif type == "string" then .
      else ""
      end
  )
}' "$transcript" | while IFS= read -r entry; do
  idx=$(echo "$entry" | jq -r '.idx')
  text=$(echo "$entry" | jq -r '.text')

  # skip already persisted messages
  grep -qxF "$idx" "$saved_index" 2>/dev/null && continue

  # only messages that open with a markdown heading qualify as plans
  echo "$text" | grep -qE '^#{1,3} ' || continue

  title=$(echo "$text" | grep -m1 -E '^#{1,3} ' | sed 's/^#\+ *//')
  [[ -z "$title" ]] && continue

  slug=$(echo "$title" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-' \
    | sed 's/-\+/-/g;s/^-//;s/-$//')

  timestamp=$(date +"%Y-%m-%dT%H-%M-%S")
  outfile="$plans_dir/${timestamp}-${slug}.md"

  printf '# %s\n\n_Saved: %s_\n\n%s\n' "$title" "$(date '+%Y-%m-%d %H:%M:%S')" "$text" > "$outfile"
  echo "$idx" >> "$saved_index"
done
