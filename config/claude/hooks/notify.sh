#!/usr/bin/env bash

# Read stdin if piped (Claude Code Notification events send JSON here)
INPUT=""
if [ ! -t 0 ]; then
    INPUT=$(cat)
fi

# Determine if this is a Notification event (JSON with notification_type field)
NOTIFICATION_TYPE=""
TITLE="Claude Code"
MESSAGE=""
if [[ -n "$INPUT" ]]; then
    # Single jq call extracts all three fields using SOH (U+0001) as delimiter
    # to avoid collisions with notification message content
    IFS=$'\001' read -r NOTIFICATION_TYPE TITLE MESSAGE < <(
        jq -r '[
            (.notification_type // ""),
            (.title // "Claude Code"),
            (.message // "")
        ] | join("")' <<< "$INPUT" 2>/dev/null
    ) || true
    [[ -z "$TITLE" ]] && TITLE="Claude Code"
fi

if [[ -n "$NOTIFICATION_TYPE" ]]; then
    # JSON path: Notification event

    case "$NOTIFICATION_TYPE" in
        permission_prompt)
            SUBTITLE="Permission Required"
            SOUND="Purr"
            ;;
        idle_prompt)
            SUBTITLE="Waiting for Input"
            SOUND="Tink"
            ;;
        elicitation_dialog)
            SUBTITLE="Question for You"
            SOUND="Purr"
            ;;
        auth_success)
            SUBTITLE="Authenticated"
            SOUND="Glass"
            ;;
        *)
            SUBTITLE="Attention Needed"
            SOUND="Default"
            ;;
    esac
else
    # Arg path: Stop / PostToolUse events
    MESSAGE="${1:-Notification}"
    TITLE="Claude Code"
    SUBTITLE=""
    SOUND="Glass"
fi

# Prepend tmux context to title
if [ -n "${TMUX:-}" ]; then
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    WINDOW=$(tmux display-message -p '#W' 2>/dev/null)
    TITLE="[${SESSION}:${WINDOW}] ${TITLE}"
fi

case "$(uname)" in
    Darwin)
        osascript - "$TITLE" "$SUBTITLE" "$MESSAGE" "$SOUND" <<'APPLESCRIPT'
on run argv
    set ttl to item 1 of argv
    set sub to item 2 of argv
    set msg to item 3 of argv
    set snd to item 4 of argv
    if sub is "" then
        display notification msg with title ttl sound name snd
    else
        display notification msg with title ttl subtitle sub sound name snd
    end if
end run
APPLESCRIPT
        ;;
    Linux)
        if command -v notify-send >/dev/null 2>&1; then
            notify-send -t 10000 "$TITLE" "$MESSAGE"
        fi
        ;;
esac
