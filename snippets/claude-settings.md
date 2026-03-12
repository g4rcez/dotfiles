---
title: claudecode
description: My default config to claudecode
shortcut: claudecode
tags:
  - claudecode
  - ai
  - anthropic
---

```json
{
  "fastMode": false,
  "effortLevel": "high",
  "env": { "ENABLE_TOOL_SEARCH": "true" },
  "attribution": { "commit": "", "pr": "" },
  "skipDangerousModePermissionPrompt": false,
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/notify.sh"
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
        "matcher": "TodoWrite",
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOME/.claude/hooks/notify.sh 'Tasks Updated'"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOME/dotfiles/config/claude/hooks/format-on-edit.sh",
            "timeout": 30
          }
        ]
      }
    ]
  },
  "enabledPlugins": {
    "rust-analyzer-lsp@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "playwright@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true
  }
}
```
