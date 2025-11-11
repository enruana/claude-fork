.PHONY: help install uninstall install-commands test clean check lint

PREFIX ?= $(HOME)/.local
BIN_DIR = $(PREFIX)/bin
LIB_DIR = $(PREFIX)/lib/claude-fork
CLAUDE_COMMANDS_DIR = $(HOME)/.claude/commands

help: ## Show this help message
	@echo "Claude Fork v1.0.0 - Makefile"
	@echo "=============================="
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install claude-fork to $(PREFIX)
	@echo "Installing Claude Fork to $(PREFIX)..."
	@./install.sh

uninstall: ## Uninstall claude-fork
	@echo "Uninstalling Claude Fork..."
	@./uninstall.sh

install-commands: ## Install slash commands only
	@echo "Installing slash commands..."
	@mkdir -p "$(CLAUDE_COMMANDS_DIR)"
	@cp -r templates/commands/* "$(CLAUDE_COMMANDS_DIR)/"
	@echo "✅ Slash commands installed to $(CLAUDE_COMMANDS_DIR)"

test: ## Run basic tests
	@echo "Running Claude Fork tests..."
	@./tests/test-suite.sh

check: ## Check dependencies and system compatibility
	@echo "Checking system compatibility..."
	@echo ""
	@echo "Operating System: $$(uname -s)"
	@echo "Shell: $$SHELL"
	@echo ""
	@echo "Dependencies:"
	@command -v bash >/dev/null 2>&1 && echo "  ✅ bash" || echo "  ❌ bash (required)"
	@command -v jq >/dev/null 2>&1 && echo "  ✅ jq" || echo "  ❌ jq (required)"
	@command -v pbcopy >/dev/null 2>&1 && echo "  ✅ pbcopy (optional)" || command -v xclip >/dev/null 2>&1 && echo "  ✅ xclip (optional)" || echo "  ⚠️  clipboard support (optional)"
	@echo ""
	@echo "Directories:"
	@echo "  Install prefix: $(PREFIX)"
	@echo "  Binary dir: $(BIN_DIR)"
	@echo "  Library dir: $(LIB_DIR)"
	@echo "  Commands dir: $(CLAUDE_COMMANDS_DIR)"

lint: ## Check shell script syntax
	@echo "Checking shell script syntax..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found, skipping..."; exit 0; }
	@shellcheck claude-fork lib/*.sh install.sh uninstall.sh || echo "⚠️  shellcheck warnings found"
	@echo "✅ Syntax check complete"

clean: ## Clean temporary files and test data
	@echo "Cleaning temporary files..."
	@rm -f /tmp/claude-fork-*
	@rm -rf /tmp/test-claude-fork-*
	@echo "✅ Cleaned temporary files"

dev-install: install ## Install in development mode (same as install)

dev-test: ## Run development tests with debug output
	@echo "Running development tests..."
	@CLAUDE_FORK_DEBUG=1 ./tests/test-suite.sh

package: ## Create distribution package
	@echo "Creating package..."
	@tar -czf claude-fork-v1.0.0.tar.gz claude-fork lib/ templates/ install.sh uninstall.sh Makefile README.md LICENSE
	@echo "✅ Package created: claude-fork-v1.0.0.tar.gz"

info: ## Show installation info
	@echo "Claude Fork Installation Info"
	@echo "============================="
	@echo ""
	@echo "Version: 1.0.0"
	@echo "Install prefix: $(PREFIX)"
	@echo "Binary location: $(BIN_DIR)/claude-fork"
	@echo "Library location: $(LIB_DIR)/"
	@echo "Commands location: $(CLAUDE_COMMANDS_DIR)/"
	@echo ""
	@if [ -f "$(BIN_DIR)/claude-fork" ]; then \
		echo "Status: ✅ Installed"; \
	else \
		echo "Status: ❌ Not installed"; \
	fi

# Development targets
.PHONY: dev-install dev-test package info