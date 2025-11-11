# Claude Fork

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/enruana/claude-fork)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-4.0%2B-orange.svg)](https://www.gnu.org/software/bash/)

> 🔀 **Manage conversation branches in Claude Code**

Claude Fork is a CLI tool that allows you to create "branches" of your Claude Code conversations, enabling you to evaluate multiple solution paths in parallel and easily share context between conversations.

## ✨ Features

- 🔀 **Fork Creation**: Spin up new Claude Code instances in separate terminals
- 📤 **Context Export**: Save results and insights from successful forks
- 📥 **Context Import**: Merge fork results back to your main conversation
- 📋 **Status Management**: Track active forks and available exports
- 🎯 **Claude Code Integration**: Native slash commands (`/fork`, `/export`, `/merge`)

## 🚀 Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/enruana/claude-fork/main/install.sh | bash
```

### Manual Installation

```bash
git clone https://github.com/enruana/claude-fork.git
cd claude-fork
make install
```

### First Fork

```bash
# Create your first fork
claude-fork new experiment-1

# List all forks and exports
claude-fork list

# Export results from a fork
claude-fork export solution-found

# Import results to main conversation
claude-fork merge solution-found
```

## 📖 Usage

### Command Line Interface

```bash
claude-fork <command> [options]

Commands:
  new [name]          Create a new fork
  export [name]       Export context from current fork
  list                List active forks and available exports
  merge <name>        Import context from an export
  clean [name]        Clean fork(s)
  help                Show help message
  version             Show version
```

### Slash Commands (Claude Code)

Use these commands directly in Claude Code:

```bash
/fork [name]        # Create new fork
/export [name]      # Export current context
/merge <name>       # Import exported context
/forks              # List status
```

## 📝 Complete Workflow Example

Here's a real-world example of using Claude Fork to evaluate different implementation approaches:

### 1. Initial Problem
You're working in Claude Code on a feature implementation and want to explore multiple approaches.

### 2. Create Forks
```bash
# In your main Claude Code conversation
/fork approach-a

# Fork A opens in new terminal
# Try implementation approach A...
# Results: Not optimal, has performance issues
# Close this terminal

# Back in main conversation
/fork approach-b

# Fork B opens in new terminal  
# Try implementation approach B...
# Results: Perfect! Works great
/export successful-solution
```

### 3. Export Successful Result
In Fork B terminal:
```bash
claude-fork export successful-solution
# Enter your summary:
Implementation B is the winner! 

Key insights:
- Uses efficient algorithm X instead of Y
- Reduces memory usage by 50%
- Handles edge cases better

Code highlights:
```js
function optimizedSolution() {
  // Implementation details...
}
```

Performance metrics:
- 200ms vs 800ms response time
- Works with datasets up to 1M records

Recommendation: Go with approach B
^D
```

### 4. Import to Main Conversation
Back in your main Claude Code conversation:
```bash
/merge successful-solution
# Content is displayed and copied to clipboard

# Then in your conversation:
Based on the fork evaluation results: [paste content]
Please implement approach B as described above.
```

### 5. Cleanup
```bash
/forks                    # See all forks
!claude-fork clean approach-a    # Remove failed fork
!claude-fork clean approach-b    # Remove successful fork
```

## 🛠️ Requirements

### Required Dependencies
- **bash** 4.0+ (pre-installed on macOS/Linux)
- **jq** (JSON processor)

### Optional Dependencies
- **pbcopy** (macOS) or **xclip** (Linux) - for clipboard support

### Installation of Dependencies

**macOS:**
```bash
brew install jq
```

**Ubuntu/Debian:**
```bash
sudo apt-get install jq xclip
```

**CentOS/RHEL/Fedora:**
```bash
sudo yum install jq xclip
# or: sudo dnf install jq xclip
```

## 📁 File Structure

After installation, Claude Fork creates:

```
~/.local/                   # Default install location
├── bin/claude-fork         # Main executable
└── lib/claude-fork/        # Library scripts
    ├── utils.sh
    ├── new.sh
    ├── export.sh
    ├── merge.sh
    ├── list.sh
    └── clean.sh

~/.claude/commands/         # Slash commands
├── fork.md
├── export.md
├── merge.md
└── forks.md

~/.claude-forks/            # User data
├── forks.json              # Fork database
└── exports/                # Exported contexts
    ├── solution-1.md
    └── experiment-results.md
```

## ⚙️ Configuration

### Custom Install Location
```bash
PREFIX=/usr/local make install
```

### Environment Variables
- `PREFIX` - Installation prefix (default: `$HOME/.local`)
- `CLAUDE_FORK_DEBUG` - Enable debug output

## 🔧 Advanced Usage

### Fork Management

**List detailed fork information:**
```bash
claude-fork list
```

**Clean specific forks:**
```bash
claude-fork clean experiment-1
claude-fork clean  # Interactive cleanup of all forks
```

### Export Management

**View available exports:**
```bash
ls ~/.claude-forks/exports/
```

**Manually edit exports:**
```bash
$EDITOR ~/.claude-forks/exports/solution-found.md
```

### Terminal Support

Claude Fork automatically detects your terminal and OS:

**macOS:**
- iTerm2 (preferred)
- Terminal.app

**Linux:**
- gnome-terminal
- konsole
- xfce4-terminal
- tilix
- xterm

## 📊 Export Format

Exports are saved as structured Markdown files:

```markdown
---
export_name: solution-found
exported_at: 2025-11-11T10:30:00-05:00
directory: /path/to/project
fork_name: approach-b
---

# Export: solution-found

Implementation B is the winner!

Key insights:
- Uses efficient algorithm X instead of Y
- Reduces memory usage by 50%
- Handles edge cases better

[Your detailed content here...]
```

## 🧪 Testing

### Run Tests
```bash
make test
```

### Check System Compatibility
```bash
make check
```

### Development Testing
```bash
make dev-test  # With debug output
```

## 🛠️ Development

### Build from Source
```bash
git clone https://github.com/enruana/claude-fork.git
cd claude-fork
make install
```

### Code Style
```bash
make lint  # Requires shellcheck
```

### Create Package
```bash
make package
```

## 🔍 Troubleshooting

### Common Issues

**"Command not found: claude-fork"**
- Add `~/.local/bin` to your PATH:
  ```bash
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  ```

**"jq: command not found"**
- Install jq: `brew install jq` (macOS) or `sudo apt-get install jq` (Linux)

**Fork doesn't open new terminal**
- Check terminal detection: `claude-fork --debug new test`
- Ensure terminal is supported (see Terminal Support section)

**Slash commands not working**
- Verify slash commands installed: `ls ~/.claude/commands/`
- Reinstall: `make install-commands`

**Permission denied**
- Ensure scripts are executable: `chmod +x ~/.local/bin/claude-fork`

### Debug Mode
```bash
CLAUDE_FORK_DEBUG=1 claude-fork new test-fork
```

### Check Installation
```bash
make info                # Show installation status
./verify-install.sh     # Comprehensive installation verification
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Setup
```bash
git clone https://github.com/enruana/claude-fork.git
cd claude-fork
make dev-install
make dev-test
```

## 📚 Examples

### Use Case 1: API Design Evaluation
```bash
# Main conversation: "I need to design an API for user management"
/fork rest-api
# Fork A: Design REST API...
# Result: Standard but verbose

/fork graphql-api  
# Fork B: Design GraphQL API...
# Result: More flexible, better for frontend
/export graphql-design

# Back to main:
/merge graphql-design
# "Based on the evaluation, implement the GraphQL approach..."
```

### Use Case 2: Bug Investigation
```bash
# Main: "There's a performance issue in the payment system"
/fork investigate-database
# Fork A: Focus on database optimization...

/fork investigate-caching
# Fork B: Focus on caching layer...
/export caching-solution

/merge caching-solution
# "The caching investigation found the root cause..."
```

### Use Case 3: Algorithm Comparison
```bash
# Main: "Need to optimize this sorting algorithm"
/fork quicksort-impl
/fork mergesort-impl  
/fork heapsort-impl

# Test each implementation...
# Export the winner...
# Merge results back
```

## 🎯 Tips & Best Practices

### Naming Conventions
- Use descriptive fork names: `fix-auth-bug`, `test-redis-cache`
- Use clear export names: `redis-performance-results`, `auth-fix-solution`

### Workflow Tips
- Create forks for any experimental work
- Export early and often from promising forks
- Use `/forks` regularly to track your exploration
- Clean up failed forks to keep your workspace tidy

### Export Content Tips
- Include the problem summary
- Document key insights and learnings
- Include relevant code snippets
- Note performance implications
- Provide clear recommendations

## 🔗 Links

- [GitHub Repository](https://github.com/enruana/claude-fork)
- [Issue Tracker](https://github.com/enruana/claude-fork/issues)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

---

**Happy Forking! 🔀**