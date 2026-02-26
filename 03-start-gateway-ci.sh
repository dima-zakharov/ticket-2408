#!/usr/bin/env bash
# CI-friendly script to start MCP gateway server in background
# Saves logs with timestamp for later review

set -ueo pipefail

source ./00-env.sh

# Kill any existing process on the port
pkill -f "mcpgateway" || true
sleep 1

# Create timestamped log file
LOG_FILE="mcpgateway-$(date +%Y%m%d-%H%M%S).log"
uv run mcpgateway --host 0.0.0.0 --port "$PORT" > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Save PID and log filename for stopping later
echo "$SERVER_PID" > .mcpgateway.pid
echo "$LOG_FILE" > .mcpgateway.logfile

# Wait for server to be ready (health check)
echo "Waiting for server to start on port $PORT..."
for i in {1..30}; do
    if curl -s "http://localhost:$PORT" > /dev/null 2>&1; then
        echo "Server started successfully (PID: $SERVER_PID, Log: $LOG_FILE)"
        exit 0
    fi
    sleep 1
done

echo "Server failed to start within 30 seconds"
cat "$LOG_FILE"
exit 1
