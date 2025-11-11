#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

check_dependencies() {
    local missing_deps=()
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install missing dependencies:"
        
        local os
        os=$(detect_os)
        case "$os" in
            macos)
                echo "  brew install jq"
                ;;
            linux)
                echo "  # Ubuntu/Debian:"
                echo "  sudo apt-get install jq"
                echo ""
                echo "  # CentOS/RHEL/Fedora:"
                echo "  sudo yum install jq"
                echo "  # or: sudo dnf install jq"
                ;;
            *)
                echo "  Please install jq for your system"
                ;;
        esac
        exit 1
    fi
}

install_claude_fork() {
    local prefix="${PREFIX:-$HOME/.local}"
    local bin_dir="$prefix/bin"
    local lib_dir="$prefix/lib/claude-fork"
    local claude_commands_dir="$HOME/.claude/commands"
    local claude_agents_dir="$HOME/.claude/agents"
    
    log_info "Installing Claude Fork v$VERSION"
    echo ""
    
    log_info "Installation directories:"
    echo "  📂 Binary: $bin_dir"
    echo "  📂 Library: $lib_dir"
    echo "  📂 Commands: $claude_commands_dir"
    echo "  📂 Agents: $claude_agents_dir"
    echo ""
    
    mkdir -p "$bin_dir" || error_exit "Failed to create bin directory: $bin_dir"
    mkdir -p "$lib_dir" || error_exit "Failed to create lib directory: $lib_dir"
    
    log_info "Copying files..."
    
    cp "$SCRIPT_DIR/claude-fork" "$bin_dir/" || error_exit "Failed to copy main script"
    chmod +x "$bin_dir/claude-fork" || error_exit "Failed to make script executable"
    
    cp -r "$SCRIPT_DIR/lib"/* "$lib_dir/" || error_exit "Failed to copy library files"
    chmod +x "$lib_dir"/*.sh || error_exit "Failed to make library scripts executable"
    
    log_success "Claude Fork installed successfully!"
    
    install_slash_commands "$claude_commands_dir"
    install_agents "$claude_agents_dir"
    
    check_path "$bin_dir"
    
    echo ""
    log_success "🎉 Installation complete!"
    echo ""
    echo "Quick start:"
    echo "  claude-fork new my-first-fork    # Create a fork"
    echo "  claude-fork list                 # List forks and exports"
    echo "  claude-fork help                 # Show all commands"
    echo ""
    echo "Slash commands (in Claude Code):"
    echo "  /cf/fork [name]                  # Create fork"
    echo "  /cf/export [name]                # Export context"
    echo "  /cf/merge <name>                 # Import context"
    echo "  /cf/forks                        # List status"
    echo "  /cf/clean                        # Clean data"
    echo "  /cf/show <name>                  # Show details"
    echo ""
    echo "Agent available:"
    echo "  export-specialist              # Expert fork management"
}

install_slash_commands() {
    local claude_commands_dir="$1"
    
    if [[ ! -d "$claude_commands_dir" ]]; then
        log_info "Creating Claude commands directory: $claude_commands_dir"
        mkdir -p "$claude_commands_dir" || {
            log_warning "Failed to create Claude commands directory"
            log_warning "Slash commands will not be available"
            return 0
        }
    fi
    
    log_info "Installing slash commands..."
    
    # Create cf subdirectory in commands
    mkdir -p "$claude_commands_dir/cf" || {
        log_warning "Failed to create cf subdirectory"
        return 0
    }
    
    # Copy cf commands to subdirectory
    cp -r "$SCRIPT_DIR/templates/commands/cf"/* "$claude_commands_dir/cf/" || {
        log_warning "Failed to install cf slash commands"
        log_warning "Manual installation: cp templates/commands/cf/* ~/.claude/commands/cf/"
        return 0
    }
    
    log_success "Slash commands installed in /cf/ namespace"
}

install_agents() {
    local claude_agents_dir="$1"
    
    if [[ ! -d "$SCRIPT_DIR/templates/agents" ]]; then
        log_warning "No agents directory found, skipping agent installation"
        return 0
    fi
    
    if [[ ! -d "$claude_agents_dir" ]]; then
        log_info "Creating Claude agents directory: $claude_agents_dir"
        mkdir -p "$claude_agents_dir" || {
            log_warning "Failed to create Claude agents directory"
            log_warning "Agents will not be available"
            return 0
        }
    fi
    
    log_info "Installing Claude Fork agents..."
    
    cp -r "$SCRIPT_DIR/templates/agents"/* "$claude_agents_dir/" || {
        log_warning "Failed to install agents"
        log_warning "Manual installation: cp templates/agents/* ~/.claude/agents/"
        return 0
    }
    
    log_success "Export Specialist agent installed"
}

check_path() {
    local bin_dir="$1"
    
    if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        log_warning "Directory $bin_dir is not in your PATH"
        echo ""
        echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"$bin_dir:\$PATH\""
        echo ""
        echo "Or run this command and restart your terminal:"
        echo "  echo 'export PATH=\"$bin_dir:\$PATH\"' >> ~/.bashrc"
        echo "  # or for zsh: echo 'export PATH=\"$bin_dir:\$PATH\"' >> ~/.zshrc"
    else
        log_success "Path is properly configured"
    fi
}

main() {
    echo "🔀 Claude Fork Installer v$VERSION"
    echo "================================="
    echo ""
    
    check_dependencies
    install_claude_fork
}

main "$@"