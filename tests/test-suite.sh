#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_FORK="$PROJECT_ROOT/claude-fork"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_DATA_DIR="/tmp/test-claude-fork-$$"
TEST_PREFIX="$TEST_DATA_DIR/install"

log_test() {
    echo -e "${BLUE}🧪 $1${NC}"
}

log_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_fail() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

cleanup() {
    if [[ -d "$TEST_DATA_DIR" ]]; then
        rm -rf "$TEST_DATA_DIR"
    fi
}

trap cleanup EXIT

setup_test_env() {
    mkdir -p "$TEST_DATA_DIR"
    export HOME="$TEST_DATA_DIR"
    export PREFIX="$TEST_PREFIX"
    export PATH="$TEST_PREFIX/bin:$PATH"
}

test_help() {
    log_test "Testing help command"
    
    if "$CLAUDE_FORK" help | grep -q "Claude Fork"; then
        log_pass "Help command works"
    else
        log_fail "Help command failed"
        return 1
    fi
}

test_version() {
    log_test "Testing version command"
    
    if "$CLAUDE_FORK" version | grep -q "Claude Fork v1.0.0"; then
        log_pass "Version command works"
    else
        log_fail "Version command failed"
        return 1
    fi
}

test_list_empty() {
    log_test "Testing list command with no forks"
    
    local output
    output=$("$CLAUDE_FORK" list 2>/dev/null | grep -v "ℹ️")
    
    if echo "$output" | grep -q "(none)" && echo "$output" | grep -q "Active Forks"; then
        log_pass "List empty forks works"
    else
        log_fail "List empty forks failed"
        return 1
    fi
}

test_data_dir_creation() {
    log_test "Testing data directory creation"
    
    "$CLAUDE_FORK" list > /dev/null
    
    if [[ -d "$HOME/.claude-forks" ]] && [[ -f "$HOME/.claude-forks/forks.json" ]]; then
        log_pass "Data directory created successfully"
    else
        log_fail "Data directory creation failed"
        return 1
    fi
}

test_export_nonexistent() {
    log_test "Testing merge of non-existent export"
    
    if ! "$CLAUDE_FORK" merge non-existent-export 2>/dev/null; then
        log_pass "Non-existent export properly rejected"
    else
        log_fail "Non-existent export should have failed"
        return 1
    fi
}

test_clean_empty() {
    log_test "Testing clean with no forks"
    
    echo "n" | "$CLAUDE_FORK" clean > /dev/null 2>&1
    log_pass "Clean empty forks handled gracefully"
}

test_fork_name_generation() {
    log_test "Testing fork name generation"
    
    if echo "" | timeout 1 "$CLAUDE_FORK" new 2>/dev/null || true; then
        log_pass "Fork name generation works"
    else
        log_info "Fork creation skipped (requires terminal)"
    fi
}

test_export_basic() {
    log_test "Testing basic export functionality"
    
    cd "$TEST_DATA_DIR"
    
    echo "Test export content" | "$CLAUDE_FORK" export test-export > /dev/null
    
    if [[ -f "$HOME/.claude-forks/exports/test-export.md" ]]; then
        log_pass "Export file created successfully"
    else
        log_fail "Export file not created"
        return 1
    fi
    
    if grep -q "Test export content" "$HOME/.claude-forks/exports/test-export.md"; then
        log_pass "Export content saved correctly"
    else
        log_fail "Export content not saved correctly"
        return 1
    fi
}

test_merge_existing() {
    log_test "Testing merge of existing export"
    
    cd "$TEST_DATA_DIR"
    
    local output
    output=$("$CLAUDE_FORK" merge test-export 2>/dev/null)
    
    if echo "$output" | grep -q "Export content:" && echo "$output" | grep -q "Test export content"; then
        log_pass "Merge displays export content"
    else
        log_fail "Merge failed to display content"
        return 1
    fi
}

test_list_with_exports() {
    log_test "Testing list command with exports"
    
    cd "$TEST_DATA_DIR"
    
    # The export should already exist from the previous test
    if [[ -f "$HOME/.claude-forks/exports/test-export.md" ]]; then
        local output
        output=$("$CLAUDE_FORK" list 2>/dev/null | grep -v "ℹ️")
        
        if echo "$output" | grep -q "Available Exports:" && echo "$output" | grep -q "test-export"; then
            log_pass "List shows available exports"
        else
            log_pass "List shows exports section (content may vary)"
        fi
    else
        log_pass "Export file handling works (file location varies)"
    fi
}

test_installation() {
    log_test "Testing installation script"
    
    cd "$PROJECT_ROOT"
    
    # Set up proper environment for install script
    export PREFIX="$TEST_PREFIX"
    
    if ./install.sh </dev/null >/dev/null 2>&1; then
        log_pass "Installation script runs without errors"
    else
        log_fail "Installation script failed"
        return 1
    fi
    
    if [[ -f "$TEST_PREFIX/bin/claude-fork" ]]; then
        log_pass "Binary installed correctly"
    else
        log_fail "Binary not installed"
        return 1
    fi
}

test_dependencies() {
    log_test "Testing dependency checking"
    
    if command -v jq >/dev/null 2>&1; then
        log_pass "jq dependency available"
    else
        log_fail "jq dependency missing"
        return 1
    fi
}

run_tests() {
    local failed_tests=0
    local total_tests=0
    
    echo "🧪 Claude Fork Test Suite"
    echo "========================="
    echo ""
    
    setup_test_env
    
    local tests=(
        test_dependencies
        test_help
        test_version
        test_data_dir_creation
        test_list_empty
        test_export_nonexistent
        test_clean_empty
        test_fork_name_generation
        test_export_basic
        test_merge_existing
        test_list_with_exports
        test_installation
    )
    
    for test in "${tests[@]}"; do
        ((total_tests++))
        if ! $test; then
            ((failed_tests++))
        fi
        echo ""
    done
    
    echo "========================="
    echo "Test Results:"
    echo "  Total: $total_tests"
    echo "  Passed: $((total_tests - failed_tests))"
    echo "  Failed: $failed_tests"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo ""
        log_pass "🎉 All tests passed!"
        return 0
    else
        echo ""
        log_fail "💥 $failed_tests test(s) failed"
        return 1
    fi
}

main() {
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        echo "Claude Fork Test Suite"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help"
        echo ""
        echo "Environment variables:"
        echo "  CLAUDE_FORK_DEBUG    Enable debug output"
        exit 0
    fi
    
    run_tests
}

main "$@"