---
allowed-tools: Bash(claude-fork:*)
description: Export context/results from current fork for later import
argument-hint: [export-name]
---

📤 Export results or context from the current fork.

This will:
- Prompt you to enter a summary/results from your fork
- Save the content as a structured markdown file
- Include metadata (timestamp, directory, fork info)
- Make it available for import in other conversations

Usage:
- `!claude-fork export` - Create auto-named export
- `!claude-fork export solution-found` - Create named export

After running this command, you'll be prompted to enter your content.

!`claude-fork export $ARGUMENTS`