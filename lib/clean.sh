#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

clean_forks() {
    local target_fork="${1:-}"
    local forks
    
    forks=$(list_forks)
    
    if [[ -z "$forks" ]]; then
        log_info "No active forks to clean"
        return 0
    fi
    
    if [[ -n "$target_fork" ]]; then
        clean_specific_fork "$target_fork"
    else
        clean_all_forks
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
        echo "💡 Note: This only marks the fork as removed in the database."
        echo "   The terminal window (if still open) is not automatically closed."
    else
        log_info "Clean cancelled"
    fi
}

clean_all_forks() {
    local fork_count
    
    fork_count=$(jq '.forks | map(select(.status == "active")) | length' "$FORKS_DB")
    
    log_warning "About to clean ALL $fork_count active forks"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_all_forks
        log_success "🗑️  All forks cleaned ($fork_count forks)"
        echo ""
        echo "💡 Note: This only marks the forks as removed in the database."
        echo "   Terminal windows (if still open) are not automatically closed."
    else
        log_info "Clean cancelled"
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        log_info "🗑️  Clean Forks"
        echo ""
        
        local forks
        forks=$(list_forks)
        
        if [[ -z "$forks" ]]; then
            echo "No active forks to clean."
            exit 0
        fi
        
        echo "Active forks:"
        echo "$forks" | while IFS=$'\t' read -r name directory created_at; do
            echo "  • $name (in $directory)"
        done
        echo ""
        
        echo "Options:"
        echo "  claude-fork clean <name>    - Clean specific fork"
        echo "  claude-fork clean           - Clean all forks (interactive)"
        echo ""
        
        read -p "Clean all forks? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup_all_forks
            log_success "🗑️  All forks cleaned"
        else
            log_info "Clean cancelled"
        fi
    else
        clean_forks "$1"
    fi
}

main "$@"