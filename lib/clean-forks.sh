#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

clean_forks() {
    local target_fork="${1:-}"
    local forks
    
    forks=$(list_forks)
    
    if [[ -z "$forks" ]]; then
        log_info "🔀 No active forks to clean"
        return 0
    fi
    
    log_info "🗑️  Clean Active Forks"
    echo ""
    
    if [[ -n "$target_fork" ]]; then
        clean_specific_fork "$target_fork"
    else
        clean_all_forks_interactive
    fi
}

clean_specific_fork() {
    local fork_name="$1"
    local fork_exists
    
    fork_exists=$(jq -e --arg name "$fork_name" '.forks[] | select(.name == $name and .status == "active")' "$FORKS_DB" 2>/dev/null || echo "")
    
    if [[ -z "$fork_exists" ]]; then
        error_exit "Fork '$fork_name' not found or not active"
    fi
    
    log_warning "About to clean fork: $fork_name"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        remove_fork "$fork_name"
        log_success "🗑️  Fork '$fork_name' cleaned"
        echo ""
        log_info "💡 Note: This only marks the fork as removed in the database."
        log_info "   The terminal window (if still open) is not automatically closed."
    else
        log_info "Clean cancelled"
    fi
}

clean_all_forks_interactive() {
    local fork_count
    
    fork_count=$(jq '.forks | map(select(.status == "active")) | length' "$FORKS_DB")
    
    echo "Active forks to clean:"
    echo "$forks" | while IFS=$'\t' read -r name directory created_at; do
        echo "  🔀 $name (in $directory)"
    done
    echo ""
    
    log_warning "About to clean ALL $fork_count active forks"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_all_forks
        log_success "🗑️  All $fork_count forks cleaned"
        echo ""
        log_info "💡 Note: This only marks the forks as removed in the database."
        log_info "   Terminal windows (if still open) are not automatically closed."
    else
        log_info "Clean cancelled"
    fi
}

show_forks_help() {
    echo "🗑️  Clean Active Forks"
    echo ""
    echo "Usage:"
    echo "  claude-fork clean-forks [fork-name]    Clean specific fork"
    echo "  claude-fork clean-forks                Clean all forks (interactive)"
    echo ""
    echo "Examples:"
    echo "  claude-fork clean-forks my-fork        Clean specific fork"
    echo "  claude-fork clean-forks                Show list and clean all"
}

main() {
    local force=false
    
    # Check for --force flag
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                force=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    if [[ $# -eq 0 ]]; then
        local forks
        forks=$(list_forks)
        
        if [[ -z "$forks" ]]; then
            log_info "🔀 No active forks to clean"
            if [[ "$force" == false ]]; then
                echo ""
                show_forks_help
            fi
            exit 0
        fi
        
        if [[ "$force" == true ]]; then
            # Non-interactive: clean all forks
            cleanup_all_forks
            log_success "🗑️  All forks cleaned"
        else
            clean_all_forks_interactive
        fi
    else
        clean_forks "$1"
    fi
}

main "$@"