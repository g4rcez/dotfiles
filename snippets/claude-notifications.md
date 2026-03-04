---
title: claude notifications
description: JSON to configure claude code notifications
shortcut: claudenotify
tags:
  - claude
  - ai
---

```json
{
    "Notification": [
        {
        "matcher": "permission_prompt|elicitation_dialog|idle_prompt",
        "hooks": [
            {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/notify.sh 'Permission Required'"
            }
        ]
        }
    ],
    "Stop": [
        {
        "hooks": [
            {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/notify.sh 'Execution Finished'"
            }
        ]
        }
    ],
    "PostToolUse": [
        {
        "matcher": "AskUserQuestion",
        "hooks": [
            {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/notify.sh 'Question Ready'"
            }
        ]
        },
        {
        "matcher": "Edit|Write",
        "hooks": [
            {
            "type": "command",
            "command": "prettier --write",
            "timeout": 5
            },
            {
            "type": "command",
            "command": "if [[ \"$CLAUDE_FILE_PATHS\" =~ \\.(ts|tsx)$ ]]; then npx tsc --noEmit --skipLibCheck \"$CLAUDE_FILE_PATHS\" || echo '⚠️ TypeScript errors detected - please review'; fi"
            }
        ]
        }
    ]
}
```
