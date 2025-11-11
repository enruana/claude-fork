---
allowed-tools: Bash(claude-fork:*)
description: Display or open an export file in editor
argument-hint: <export-name> [action]
required-args: 1
---

📄 Display or open an export file for review.

This will:
- Show the export content in the terminal (default)
- Or open it in your preferred editor (code, cursor, etc.)
- Display file information and metadata

Actions available:
- `display` (default) - Show in terminal with formatting
- `edit` - Open in default editor ($EDITOR)
- `code` - Open in VS Code
- `cursor` - Open in Cursor editor

Usage examples:
- `!claude-fork show my-export` - Display in terminal
- `!claude-fork show my-export code` - Open in VS Code
- `!claude-fork show my-export cursor` - Open in Cursor

!`claude-fork show $ARGUMENTS`