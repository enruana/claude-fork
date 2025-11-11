#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

generate_export_prompt() {
    local export_name="$1"
    local current_dir="$2"
    
    cat << EOF
Please create a structured export summary for this Claude Fork session.

**Export Name:** $export_name
**Working Directory:** $current_dir

Analyze our recent conversation and create a comprehensive export with these sections:

## Summary
Brief overview of what was accomplished or discussed in this fork

## Key Insights  
Important findings, decisions, or learnings from our work

## Technical Details
Code changes, commands, or technical solutions we implemented

## Outcomes
Results achieved or next steps identified

## Recommendations
Suggestions for the main conversation based on this fork's work

Format as clear markdown. Focus on actionable insights and concrete results from our actual conversation in this fork.
EOF
}

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
    
    # Check for different modes
    local save_content=""
    local manual_mode=false
    
    # Parse arguments for --save-content
    for arg in "$@"; do
        if [[ "$arg" == "--manual" ]]; then
            manual_mode=true
        elif [[ "$arg" == --save-content=* ]]; then
            save_content="${arg#--save-content=}"
        fi
    done
    
    if [[ -n "$save_content" ]]; then
        # Save content mode: content provided as argument
        content="$save_content"
        log_success "📝 Content provided via --save-content"
    elif [[ "$manual_mode" == true ]]; then
        # Manual entry mode
        log_info "Manual content entry mode"
        echo "Enter your export content (summary/results from this fork):"
        echo "Type your content and press Ctrl+D when finished:"
        echo "----------------------------------------"
        content="$(cat)"
        
        if [[ -z "$content" ]]; then
            error_exit "No content provided for export"
        fi
    else
        # Interactive mode: show prompt and wait for input
        log_info "📝 Two-phase export for: $export_name"
        echo ""
        echo "STEP 1: Copy this prompt and ask Claude to create the export summary:"
        echo ""
        echo "$(generate_export_prompt "$export_name" "$current_dir")"
        echo ""
        echo "STEP 2: Paste Claude's response below and press Ctrl+D:"
        echo "----------------------------------------"
        
        content="$(cat)"
        
        if [[ -z "$content" ]]; then
            error_exit "No content provided for export"
        fi
        
        log_success "📝 Export content provided"
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
    echo "  • Or use the slash command: cf:merge $export_name"
}

main() {
    export_context "$@"
}

main "$@"