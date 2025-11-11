#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

clean_exports() {
    local target_export="${1:-}"
    local exports
    
    exports=$(list_exports)
    
    if [[ -z "$exports" ]]; then
        log_info "📦 No exports to clean"
        return 0
    fi
    
    log_info "🗑️  Clean Export Files"
    echo ""
    
    if [[ -n "$target_export" ]]; then
        clean_specific_export "$target_export"
    else
        clean_exports_interactive
    fi
}

clean_specific_export() {
    local export_name="$1"
    local export_file
    
    export_file="$(get_export_path "$export_name")"
    
    if ! export_exists "$export_name"; then
        error_exit "Export '$export_name' not found at: $export_file"
    fi
    
    log_warning "About to delete export: $export_name"
    echo "  📄 File: $export_file"
    echo ""
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$export_file"
        log_success "🗑️  Export '$export_name' deleted"
    else
        log_info "Delete cancelled"
    fi
}

clean_exports_interactive() {
    local export_count=0
    local export_files=()
    
    # Count and collect exports
    while IFS= read -r export_file; do
        if [[ -n "$export_file" ]]; then
            export_files+=("$export_file")
            ((export_count++))
        fi
    done <<< "$exports"
    
    if [[ $export_count -eq 0 ]]; then
        log_info "📦 No exports found"
        return 0
    fi
    
    echo "Available exports to clean:"
    for export_file in "${export_files[@]}"; do
        local name metadata exported_at
        name=$(basename "$export_file" .md)
        
        # Try to get export date
        if [[ -f "$export_file" ]] && grep -q "^exported_at:" "$export_file" 2>/dev/null; then
            exported_at=$(grep "^exported_at:" "$export_file" | cut -d' ' -f2- | head -1)
            echo "  📄 $name (exported: $exported_at)"
        else
            echo "  📄 $name"
        fi
    done
    echo ""
    
    echo "Cleanup options:"
    echo "  1) Delete specific export"
    echo "  2) Delete ALL exports"
    echo "  3) Delete exports older than X days"
    echo "  4) Cancel"
    echo ""
    read -p "Choose option (1-4): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            echo ""
            read -p "Enter export name to delete: " specific_name
            if [[ -n "$specific_name" ]]; then
                clean_specific_export "$specific_name"
            fi
            ;;
        2)
            echo ""
            log_warning "About to delete ALL $export_count exports"
            read -p "Are you sure? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                clean_all_exports
            else
                log_info "Clean cancelled"
            fi
            ;;
        3)
            echo ""
            read -p "Delete exports older than how many days? " days
            if [[ "$days" =~ ^[0-9]+$ ]] && [[ "$days" -gt 0 ]]; then
                clean_old_exports "$days"
            else
                log_error "Invalid number of days"
            fi
            ;;
        4|*)
            log_info "Clean cancelled"
            ;;
    esac
}

clean_all_exports() {
    local deleted_count=0
    
    while IFS= read -r export_file; do
        if [[ -n "$export_file" && -f "$export_file" ]]; then
            rm -f "$export_file"
            ((deleted_count++))
        fi
    done <<< "$exports"
    
    log_success "🗑️  Deleted $deleted_count export files"
}

clean_old_exports() {
    local days="$1"
    local deleted_count=0
    
    log_info "🕒 Deleting exports older than $days days..."
    
    # Use find to delete files older than specified days
    if [[ -d "$EXPORTS_DIR" ]]; then
        local found_files
        found_files=$(find "$EXPORTS_DIR" -name "*.md" -type f -mtime +$days 2>/dev/null || true)
        
        if [[ -n "$found_files" ]]; then
            while IFS= read -r export_file; do
                if [[ -n "$export_file" ]]; then
                    local name
                    name=$(basename "$export_file" .md)
                    echo "  Deleting: $name"
                    rm -f "$export_file"
                    ((deleted_count++))
                fi
            done <<< "$found_files"
        fi
    fi
    
    if [[ $deleted_count -gt 0 ]]; then
        log_success "🗑️  Deleted $deleted_count exports older than $days days"
    else
        log_info "📦 No exports found older than $days days"
    fi
}

show_exports_help() {
    echo "🗑️  Clean Export Files"
    echo ""
    echo "Usage:"
    echo "  claude-fork clean-exports [export-name]    Delete specific export"
    echo "  claude-fork clean-exports                  Interactive cleanup menu"
    echo ""
    echo "Examples:"
    echo "  claude-fork clean-exports my-export        Delete specific export"
    echo "  claude-fork clean-exports                  Show interactive menu"
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
        local exports
        exports=$(list_exports)
        
        if [[ -z "$exports" ]]; then
            log_info "📦 No exports to clean"
            if [[ "$force" == false ]]; then
                echo ""
                show_exports_help
            fi
            exit 0
        fi
        
        if [[ "$force" == true ]]; then
            # Non-interactive: clean all exports
            clean_all_exports
        else
            clean_exports_interactive
        fi
    else
        clean_exports "$1"
    fi
}

main "$@"