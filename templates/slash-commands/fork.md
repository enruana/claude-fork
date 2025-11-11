---
allowed-tools: Bash(claude-fork:*)
description: Create a new conversation fork in a separate terminal
argument-hint: [fork-name]
---

🔀 Create a new fork to explore an alternative solution path.

This will:
- Open a new terminal window with Claude Code
- Create a fork entry in the database
- Set up the same working directory
- Allow parallel exploration of different approaches

Usage:
- `!claude-fork new` - Create auto-named fork
- `!claude-fork new my-fork-name` - Create named fork

!`claude-fork new $ARGUMENTS`