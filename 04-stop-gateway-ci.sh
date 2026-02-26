#!/usr/bin/env bash
# CI-friendly script to stop MCP gateway server

set -ueo pipefail

if [[ -f .mcpgateway.pid ]]; then
	PID=$(cat .mcpgateway.pid)
	kill "$PID" 2>/dev/null || true
	rm .mcpgateway.pid
	echo "Stopped server (PID: $PID)"
else
	pkill -f "mcpgateway" || true
	echo "Stopped any running mcpgateway processes"
fi

# Show log file location for review
if [[ -f .mcpgateway.logfile ]]; then
	LOG_FILE=$(cat .mcpgateway.logfile)
	echo "Server logs saved to: $LOG_FILE"
	rm .mcpgateway.logfile
fi
