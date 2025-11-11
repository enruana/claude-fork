#!/bin/bash

set -euo pipefail

VERSION="1.0.0"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DATA_DIR="$HOME/.claude-forks"
FORKS_DB="$DATA_DIR/forks.json"
EXPORTS_DIR="$DATA_DIR/exports"

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

init_data_dir() {
    if [[ ! -d "$DATA_DIR" ]]; then
        mkdir -p "$DATA_DIR" || error_exit "Failed to create data directory: $DATA_DIR"
        log_info "Created data directory: $DATA_DIR"
    fi
    
    if [[ ! -d "$EXPORTS_DIR" ]]; then
        mkdir -p "$EXPORTS_DIR" || error_exit "Failed to create exports directory: $EXPORTS_DIR"
        log_info "Created exports directory: $EXPORTS_DIR"
    fi
    
    if [[ ! -f "$FORKS_DB" ]]; then
        echo '{"forks": []}' > "$FORKS_DB" || error_exit "Failed to create forks database"
        log_info "Initialized forks database: $FORKS_DB"
    fi
}

check_dependencies() {
    local missing_deps=()
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error_exit "Missing required dependencies: ${missing_deps[*]}. Please install them first."
    fi
}

get_current_directory() {
    pwd
}

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

detect_terminal() {
    local os
    os=$(detect_os)
    
    case "$os" in
        macos)
            if [[ -d "/Applications/iTerm.app" ]]; then
                echo "iterm2"
            else
                echo "terminal"
            fi
            ;;
        linux)
            if [[ -n "${GNOME_TERMINAL_SERVICE:-}" ]]; then
                echo "gnome-terminal"
            elif command -v konsole >/dev/null 2>&1; then
                echo "konsole"
            elif command -v xfce4-terminal >/dev/null 2>&1; then
                echo "xfce4-terminal"
            elif command -v tilix >/dev/null 2>&1; then
                echo "tilix"
            elif command -v xterm >/dev/null 2>&1; then
                echo "xterm"
            else
                echo "unknown"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

open_terminal() {
    local fork_name="$1"
    local directory="$2"
    local terminal
    local os
    
    terminal=$(detect_terminal)
    os=$(detect_os)
    
    case "$os" in
        macos)
            case "$terminal" in
                iterm2)
                    osascript <<EOF
tell application "iTerm2"
    create window with default profile
    tell current session of current window
        write text "cd \"$directory\" && claude --resume"
        set name to "Claude Fork: $fork_name"
    end tell
end tell
EOF
                    ;;
                terminal)
                    osascript <<EOF
tell application "Terminal"
    do script "cd \"$directory\" && claude --resume"
    set custom title of front window to "Claude Fork: $fork_name"
end tell
EOF
                    ;;
                *)
                    error_exit "Unsupported terminal on macOS: $terminal"
                    ;;
            esac
            ;;
        linux)
            case "$terminal" in
                gnome-terminal)
                    gnome-terminal --title="Claude Fork: $fork_name" --working-directory="$directory" -- bash -c "claude --resume; exec bash"
                    ;;
                konsole)
                    konsole --new-tab --workdir "$directory" --title "Claude Fork: $fork_name" -e bash -c "claude --resume; exec bash"
                    ;;
                xfce4-terminal)
                    xfce4-terminal --title="Claude Fork: $fork_name" --working-directory="$directory" --command="bash -c 'claude --resume; exec bash'"
                    ;;
                tilix)
                    tilix --new-window --working-directory="$directory" --title="Claude Fork: $fork_name" --command="bash -c 'claude --resume; exec bash'"
                    ;;
                xterm)
                    xterm -T "Claude Fork: $fork_name" -e "cd '$directory' && claude --resume; exec bash" &
                    ;;
                *)
                    error_exit "Unsupported terminal on Linux: $terminal"
                    ;;
            esac
            ;;
        *)
            error_exit "Unsupported operating system: $os"
            ;;
    esac
}

generate_fork_name() {
    echo "fork-$(date +%Y%m%d-%H%M%S)"
}

generate_export_name() {
    echo "export-$(date +%Y%m%d-%H%M%S)"
}

add_fork() {
    local name="$1"
    local directory="$2"
    local parent_pid="$$"
    local created_at
    
    created_at=$(date -Iseconds)
    
    local temp_file
    temp_file=$(mktemp)
    
    jq --arg name "$name" \
       --arg directory "$directory" \
       --arg parent_pid "$parent_pid" \
       --arg created_at "$created_at" \
       '.forks += [{
           "name": $name,
           "directory": $directory,
           "parent_pid": $parent_pid,
           "created_at": $created_at,
           "status": "active"
       }]' "$FORKS_DB" > "$temp_file" || error_exit "Failed to update forks database"
    
    mv "$temp_file" "$FORKS_DB" || error_exit "Failed to save forks database"
}

list_forks() {
    jq -r '.forks[] | select(.status == "active") | "\(.name)\t\(.directory)\t\(.created_at)"' "$FORKS_DB" 2>/dev/null || echo ""
}

list_exports() {
    if [[ -d "$EXPORTS_DIR" ]]; then
        find "$EXPORTS_DIR" -name "*.md" -type f 2>/dev/null | sort || true
    else
        true
    fi
}

remove_fork() {
    local name="$1"
    local temp_file
    temp_file=$(mktemp)
    
    jq --arg name "$name" '.forks = (.forks | map(if .name == $name then .status = "removed" else . end))' "$FORKS_DB" > "$temp_file" || error_exit "Failed to update forks database"
    
    mv "$temp_file" "$FORKS_DB" || error_exit "Failed to save forks database"
}

cleanup_all_forks() {
    local temp_file
    temp_file=$(mktemp)
    
    jq '.forks = (.forks | map(.status = "removed"))' "$FORKS_DB" > "$temp_file" || error_exit "Failed to update forks database"
    
    mv "$temp_file" "$FORKS_DB" || error_exit "Failed to save forks database"
}

get_export_path() {
    local name="$1"
    echo "$EXPORTS_DIR/$name.md"
}

export_exists() {
    local name="$1"
    [[ -f "$(get_export_path "$name")" ]]
}

has_clipboard() {
    command -v pbcopy >/dev/null 2>&1 || command -v xclip >/dev/null 2>&1
}

copy_to_clipboard() {
    local content="$1"
    
    if command -v pbcopy >/dev/null 2>&1; then
        echo "$content" | pbcopy
    elif command -v xclip >/dev/null 2>&1; then
        echo "$content" | xclip -selection clipboard
    else
        return 1
    fi
}

show_help() {
    cat << EOF
Claude Fork v$VERSION - Manage conversation branches in Claude Code

Usage: claude-fork <command> [options]

Commands:
  new [name]              Create a new fork (default command)
  export [name]           Export result from current fork (auto-generated with Claude)
  export [name] --manual  Export with manual content entry
  list                    List active forks and available exports
  merge <name>            Import context from an export
  show <name> [action]    Display or open an export file
  clean [name]            Clean fork(s) - specific name or all if no name
  help                    Show this help message
  version                 Show version information

Examples:
  claude-fork new eval-option-1          Create named fork
  claude-fork new                        Create auto-named fork
  claude-fork export solution-found      Auto-generate export with Claude
  claude-fork export test --manual       Create export with manual input
  claude-fork list                       Show all forks and exports
  claude-fork show solution-found        Display export content in terminal
  claude-fork show solution-found code   Open export in VS Code
  claude-fork show solution-found cursor Open export in Cursor
  claude-fork merge solution-found       Import exported context
  claude-fork clean eval-option-1        Remove specific fork
  claude-fork clean                      Remove all forks

Slash Commands (for use in Claude Code - now with cf: prefix):
  cf:fork [name]      - Execute: claude-fork new [name]
  cf:export [name]    - Execute: claude-fork export [name]
  cf:merge <name>     - Execute: claude-fork merge <name>
  cf:forks            - Execute: claude-fork list
  cf:show <name>      - Execute: claude-fork show <name>

For more information, visit: https://github.com/enruana/claude-fork
EOF
}

show_version() {
    echo "Claude Fork v$VERSION"
}