#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

export_context() {
    local export_name="${1:-}"
    local current_dir
    local export_file
    local content
    
    current_dir="$(get_current_directory)"
    
    if [[ -z "$export_name" ]]; then
        export_name="$(generate_export_name)"
        log_info "Auto-generated export name: $export_name"
    fi
    
    export_file="$(get_export_path "$export_name")"
    
    if export_exists "$export_name"; then
        log_warning "Export '$export_name' already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Export cancelled"
            return 0
        fi
    fi
    
    log_info "📤 Creating export: $export_name"
    echo ""
    echo "Enter your export content (summary/results from this fork):"
    echo "Type your content and press Ctrl+D when finished:"
    echo "----------------------------------------"
    
    content="$(cat)"
    
    if [[ -z "$content" ]]; then
        error_exit "No content provided for export"
    fi
    
    cat > "$export_file" << EOF
---
export_name: $export_name
exported_at: $(date -Iseconds)
directory: $current_dir
fork_name: ${FORK_NAME:-$(basename "$current_dir")}
---

# Export: $export_name

$content
EOF
    
    log_success "Export saved to: $export_file"
    echo ""
    echo "Export details:"
    echo "  📁 Name: $export_name"
    echo "  📂 Directory: $current_dir"
    echo "  📄 File: $export_file"
    echo ""
    echo "Next steps:"
    echo "  • Use 'claude-fork merge $export_name' in your main conversation"
    echo "  • Or use the slash command: /merge $export_name"
}

main() {
    export_context "$@"
}

main "$@"