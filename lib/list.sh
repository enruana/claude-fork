#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

list_all() {
    local forks
    local exports
    local has_content=false
    
    log_info "📋 Claude Fork Status"
    echo ""
    
    forks=$(list_forks)
    if [[ -n "$forks" ]]; then
        echo "🔀 Active Forks:"
        echo "----------------"
        echo "$forks" | while IFS=$'\t' read -r name directory created_at; do
            echo "  📁 $name"
            echo "     Directory: $directory"
            echo "     Created: $created_at"
            echo ""
        done
        has_content=true
    else
        echo "🔀 Active Forks: (none)"
        echo ""
    fi
    
    exports=$(list_exports)
    if [[ -n "$exports" ]]; then
        echo "📦 Available Exports:"
        echo "---------------------"
        
        # Use a different approach to avoid pipe issues
        while IFS= read -r export_file; do
            if [[ -z "$export_file" ]]; then
                continue
            fi
            
            local name metadata
            name=$(basename "$export_file" .md)
            
            if [[ -f "$export_file" ]] && grep -q "^---$" "$export_file" 2>/dev/null; then
                # Simple grep approach - more reliable across systems
                local exported_at directory fork_name
                exported_at=$(grep "^exported_at:" "$export_file" | cut -d' ' -f2- | head -1)
                directory=$(grep "^directory:" "$export_file" | cut -d' ' -f2- | head -1)
                fork_name=$(grep "^fork_name:" "$export_file" | cut -d' ' -f2- | head -1)
                
                # Provide fallbacks
                [[ -z "$exported_at" ]] && exported_at="unknown"
                [[ -z "$directory" ]] && directory="unknown"
                [[ -z "$fork_name" ]] && fork_name="unknown"
                
                echo "  📄 $name"
                echo "     From fork: $fork_name"
                echo "     Directory: $directory"
                echo "     Exported: $exported_at"
                echo ""
            else
                echo "  📄 $name"
                echo "     File: $export_file"
                echo ""
            fi
        done <<< "$exports"
        has_content=true
    else
        echo "📦 Available Exports: (none)"
        echo ""
    fi
    
    if [[ "$has_content" == true ]]; then
        echo "Commands:"
        echo "  claude-fork new [name]      - Create new fork"
        echo "  claude-fork export [name]   - Export from current fork"
        echo "  claude-fork merge <name>    - Import export to main conversation"
        echo "  claude-fork clean [name]    - Clean fork(s)"
    else
        echo "💡 Get started:"
        echo "  claude-fork new my-fork     - Create your first fork"
        echo "  claude-fork help           - Show all commands"
    fi
}

main() {
    list_all
}

main "$@"