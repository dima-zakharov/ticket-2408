PORT ?= 8080

.PHONY: help start stop

help:
	@echo "Available targets:"
	@echo "  help   - Show this help message"
	@echo "  start  - Start the MCP gateway server"
	@echo "  stop   - Stop the MCP gateway server"

start:
	source ./00-env.sh && tmux new-session -d -s gateway "uv run mcpgateway --host 0.0.0.0 --port $(PORT)" \; pipe-pane 'cat > mcpgateway.log'

stop:
	source ./00-env.sh && tmux kill-session -t gateway
