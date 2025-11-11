---
allowed-tools: Bash(claude-fork:*)
description: Import context from an exported fork
argument-hint: <export-name>
required-args: 1
---

📥 Import context/results from a previously exported fork.

This will:
- Display the content of the exported fork
- Copy the content to your clipboard (if available)
- Provide instructions for using in your conversation

The export name is required. Use `/forks` to see available exports.

Usage:
- `!claude-fork merge solution-found` - Import specific export

After running this command, paste the content in your conversation with appropriate context.

!`claude-fork merge $ARGUMENTS`