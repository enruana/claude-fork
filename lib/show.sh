#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

show_export() {
    local export_name="$1"
    local export_file
    local action="${2:-display}"
    
    if [[ -z "$export_name" ]]; then
        log_error "Export name is required. Usage: claude-fork show <export-name> [action]"
        echo ""
        echo "Available exports:"
        local exports
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
        echo "Actions: display (default), edit, code, cursor"
        exit 1
    fi
    
    export_file="$(get_export_path "$export_name")"
    
    if ! export_exists "$export_name"; then
        error_exit "Export '$export_name' not found at: $export_file"
    fi
    
    log_info "📄 Showing export: $export_name"
    echo ""
    
    case "$action" in
        display|show)
            # Display in terminal with syntax highlighting if possible
            if command -v bat >/dev/null 2>&1; then
                bat --style=header,grid --language=markdown "$export_file"
            elif command -v pygmentize >/dev/null 2>&1; then
                pygmentize -l markdown "$export_file"
            else
                # Fallback to cat with simple formatting
                echo "File: $export_file"
                echo "$(printf '=%.0s' {1..50})"
                cat "$export_file"
                echo "$(printf '=%.0s' {1..50})"
            fi
            ;;
        edit|editor)
            # Open in default editor
            if [[ -n "${EDITOR:-}" ]]; then
                "$EDITOR" "$export_file"
            elif command -v nano >/dev/null 2>&1; then
                nano "$export_file"
            elif command -v vim >/dev/null 2>&1; then
                vim "$export_file"
            else
                error_exit "No suitable editor found. Set EDITOR environment variable."
            fi
            ;;
        code|vscode)
            # Open in VS Code
            if command -v code >/dev/null 2>&1; then
                code "$export_file"
                log_success "Opened in VS Code"
            else
                error_exit "VS Code (code command) not found"
            fi
            ;;
        cursor)
            # Open in Cursor
            if command -v cursor >/dev/null 2>&1; then
                cursor "$export_file"
                log_success "Opened in Cursor"
            else
                error_exit "Cursor editor not found"
            fi
            ;;
        *)
            error_exit "Unknown action: $action. Available: display, edit, code, cursor"
            ;;
    esac
    
    echo ""
    echo "Export details:"
    echo "  📁 Name: $export_name"
    echo "  📄 File: $export_file"
    echo "  📊 Size: $(wc -l < "$export_file" | xargs) lines"
}

main() {
    if [[ $# -eq 0 ]]; then
        log_error "Export name is required"
        echo ""
        echo "Usage: claude-fork show <export-name> [action]"
        echo ""
        echo "Available exports:"
        local exports
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
        echo "Actions:"
        echo "  display    Show content in terminal (default)"
        echo "  edit       Open in default editor (\$EDITOR)"
        echo "  code       Open in VS Code"
        echo "  cursor     Open in Cursor editor"
        exit 1
    fi
    
    show_export "$@"
}

main "$@"