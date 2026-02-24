#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh

tmux new-session -d -s gateway  "uvx --from mcp-contextforge-gateway mcpgateway --host 0.0.0.0 --port $PORT"

