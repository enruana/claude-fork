#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

create_fork() {
    local fork_name="${1:-}"
    local current_dir
    
    current_dir="$(get_current_directory)"
    
    if [[ -z "$fork_name" ]]; then
        fork_name="$(generate_fork_name)"
        log_info "Auto-generated fork name: $fork_name"
    fi
    
    if jq -e --arg name "$fork_name" '.forks[] | select(.name == $name and .status == "active")' "$FORKS_DB" >/dev/null 2>&1; then
        error_exit "Fork '$fork_name' already exists and is active"
    fi
    
    log_info "Creating fork '$fork_name' in directory: $current_dir"
    
    add_fork "$fork_name" "$current_dir"
    
    log_info "Opening new terminal for fork: $fork_name"
    
    open_terminal "$fork_name" "$current_dir"
    
    log_success "Fork '$fork_name' created successfully!"
    log_info "🔀 New terminal opened with Claude Code ready"
    log_info "📂 Working directory: $current_dir"
    echo ""
    echo "Next steps:"
    echo "  • Work on your alternative solution in the new terminal"
    echo "  • When ready, use 'claude-fork export [name]' to save results"
    echo "  • Use 'claude-fork merge <name>' to bring results back to main conversation"
}

main() {
    create_fork "$@"
}

main "$@"