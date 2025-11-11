#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

auto_export() {
    local export_name="${1:-$(generate_export_name)}"
    local current_dir="$(get_current_directory)"
    
    log_info "🤖 Starting automatic two-phase export: $export_name"
    
    # Phase 1: Generate the prompt for Claude
    local prompt="Please create a structured export summary for this Claude Fork session.

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

Format as clear markdown. Focus on actionable insights and concrete results from our actual conversation in this fork."

    echo "📝 PHASE 1: AI Summary Generation"
    echo "================================="
    echo ""
    echo "$prompt"
    echo ""
    echo "📁 PHASE 2: Auto-Save (will execute after your response)"
    echo "========================================================"
    echo ""
    echo "After you provide the summary above, I'll automatically save it using:"
    echo "claude-fork export $export_name --auto-save"
}

main() {
    auto_export "$@"
}

main "$@"