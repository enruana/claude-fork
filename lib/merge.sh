#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

merge_context() {
    local export_name="$1"
    local export_file
    local content
    
    if [[ -z "$export_name" ]]; then
        error_exit "Export name is required. Usage: claude-fork merge <export-name>"
    fi
    
    export_file="$(get_export_path "$export_name")"
    
    if ! export_exists "$export_name"; then
        error_exit "Export '$export_name' not found at: $export_file"
    fi
    
    log_info "📥 Merging export: $export_name"
    echo ""
    
    if grep -q "^---$" "$export_file"; then
        local metadata_end
        metadata_end=$(grep -n "^---$" "$export_file" | tail -n1 | cut -d: -f1)
        if [[ -n "$metadata_end" ]]; then
            metadata_end=$((metadata_end + 1))
            content=$(tail -n +$metadata_end "$export_file")
        else
            content=$(cat "$export_file")
        fi
    else
        content=$(cat "$export_file")
    fi
    
    echo "Export content:"
    echo "==============="
    echo "$content"
    echo "==============="
    echo ""
    
    if has_clipboard; then
        if copy_to_clipboard "$content"; then
            log_success "Export content copied to clipboard! 📋"
            echo ""
            echo "Next steps:"
            echo "  • Paste the content in your main Claude Code conversation"
            echo "  • Prefix with context like: 'Based on the fork evaluation:'"
        else
            log_warning "Failed to copy to clipboard"
        fi
    else
        log_info "💡 Copy the content above and paste it in your main conversation"
    fi
    
    echo ""
    echo "Suggested usage in Claude Code:"
    echo "  \"Based on the fork evaluation results:\""
    echo "  [paste the content above]"
    echo "  \"Please implement this solution...\""
}

main() {
    if [[ $# -eq 0 ]]; then
        log_error "Export name is required"
        echo ""
        echo "Available exports:"
        exports=$(list_exports)
        if [[ -n "$exports" ]]; then
            echo "$exports" | while read -r export_file; do
                local name
                name=$(basename "$export_file" .md)
                echo "  • $name"
            done
        else
            echo "  (no exports found)"
        fi
        echo ""
        echo "Usage: claude-fork merge <export-name>"
        exit 1
    fi
    
    merge_context "$1"
}

main "$@"