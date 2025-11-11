#!/bin/bash

set -euo pipefail

VERSION="1.0.0"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

uninstall_claude_fork() {
    local prefix="${PREFIX:-$HOME/.local}"
    local bin_dir="$prefix/bin"
    local lib_dir="$prefix/lib/claude-fork"
    local claude_commands_dir="$HOME/.claude/commands"
    local legacy_data_dir="$HOME/.claude-forks"  # Legacy global data directory
    
    echo "🗑️  Claude Fork Uninstaller v$VERSION"
    echo "====================================="
    echo ""
    
    log_warning "This will remove Claude Fork from your system"
    echo ""
    echo "Files to be removed:"
    echo "  📄 $bin_dir/claude-fork"
    echo "  📂 $lib_dir/"
    echo "  📂 $claude_commands_dir/{fork,export,merge,forks}.md"
    echo ""
    echo "User data (will ask separately):"
    echo "  📂 $legacy_data_dir/ (legacy global data)"
    echo ""
    
    read -p "Continue with uninstallation? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled"
        exit 0
    fi
    
    log_info "Removing Claude Fork..."
    
    if [[ -f "$bin_dir/claude-fork" ]]; then
        rm -f "$bin_dir/claude-fork" && log_success "Removed main script"
    else
        log_warning "Main script not found at: $bin_dir/claude-fork"
    fi
    
    if [[ -d "$lib_dir" ]]; then
        rm -rf "$lib_dir" && log_success "Removed library directory"
    else
        log_warning "Library directory not found at: $lib_dir"
    fi
    
    local commands_removed=0
    for cmd in fork export merge forks; do
        local cmd_file="$claude_commands_dir/$cmd.md"
        if [[ -f "$cmd_file" ]]; then
            rm -f "$cmd_file" && ((commands_removed++))
        fi
    done
    
    if [[ $commands_removed -gt 0 ]]; then
        log_success "Removed $commands_removed slash commands"
    else
        log_warning "No slash commands found to remove"
    fi
    
    if [[ -d "$legacy_data_dir" ]]; then
        echo ""
        log_warning "Legacy user data found at: $legacy_data_dir"
        echo ""
        echo "This contains:"
        echo "  • Fork database (forks.json)"
        echo "  • Exported contexts (exports/*.md)"
        echo ""
        read -p "Remove user data as well? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$legacy_data_dir" && log_success "Removed legacy user data directory"
        else
            log_info "Legacy user data preserved at: $legacy_data_dir"
        fi
    fi
    
    echo ""
    log_success "🎉 Claude Fork uninstalled successfully!"
    echo ""
    echo "Thank you for using Claude Fork!"
    
    if [[ -d "$legacy_data_dir" ]]; then
        echo ""
        echo "Note: Legacy user data preserved at $legacy_data_dir"
        echo "You can manually remove it later if needed:"
        echo "  rm -rf \"$legacy_data_dir\""
    fi
    echo ""
    echo "💡 Note: Claude Fork now stores data locally per project in .claude/.claude-fork/"
}

main() {
    uninstall_claude_fork
}

main "$@"