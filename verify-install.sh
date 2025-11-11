#!/bin/bash

# Claude Fork Installation Verification Script
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib/claude-fork"

echo "🔍 Claude Fork Installation Verification"
echo "========================================"
echo ""

# Check binary exists
if [[ -f "$BIN_DIR/claude-fork" ]]; then
    echo "✅ Binary found: $BIN_DIR/claude-fork"
else
    echo "❌ Binary not found: $BIN_DIR/claude-fork"
    exit 1
fi

# Check library directory exists  
if [[ -d "$LIB_DIR" ]]; then
    echo "✅ Library directory found: $LIB_DIR"
else
    echo "❌ Library directory not found: $LIB_DIR"
    exit 1
fi

# Check individual library files
LIB_FILES=("utils.sh" "new.sh" "export.sh" "merge.sh" "list.sh" "clean.sh")
for file in "${LIB_FILES[@]}"; do
    if [[ -f "$LIB_DIR/$file" ]]; then
        echo "✅ Library file found: $file"
    else
        echo "❌ Library file missing: $file"
        exit 1
    fi
done

# Test the binary can run
echo ""
echo "🧪 Testing binary execution..."
if "$BIN_DIR/claude-fork" version >/dev/null 2>&1; then
    echo "✅ Binary executes successfully"
    echo "Version: $("$BIN_DIR/claude-fork" version)"
else
    echo "❌ Binary execution failed"
    echo ""
    echo "Debug info:"
    echo "PATH: $PATH"
    echo "Binary path: $BIN_DIR/claude-fork"
    echo "Library path: $LIB_DIR"
    echo ""
    echo "Attempting to run with debug info..."
    "$BIN_DIR/claude-fork" version 2>&1 || true
    exit 1
fi

# Test slash commands if Claude directory exists
if [[ -d "$HOME/.claude/commands" ]]; then
    echo ""
    echo "🔍 Checking slash commands..."
    SLASH_COMMANDS=("fork.md" "export.md" "merge.md" "forks.md")
    for cmd in "${SLASH_COMMANDS[@]}"; do
        if [[ -f "$HOME/.claude/commands/$cmd" ]]; then
            echo "✅ Slash command found: $cmd"
        else
            echo "⚠️  Slash command missing: $cmd"
        fi
    done
fi

echo ""
echo "✅ 🎉 Claude Fork installation verified successfully!"
echo ""
echo "Quick start:"
echo "  claude-fork new my-fork"
echo "  claude-fork list"
echo "  claude-fork help"