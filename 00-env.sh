#!/usr/bin/env -S bash

set -ueo pipefail

PORT=${PORT:=4444}

# env vars
export BASIC_AUTH_PASSWORD="$(cat ~/.local/ticket-24008-pass)" 
export MCPGATEWAY_UI_ENABLED=true 
export MCPGATEWAY_ADMIN_API_ENABLED=true 
export PLATFORM_ADMIN_EMAIL=admin@example.com 
export PLATFORM_ADMIN_PASSWORD=changeme 
export PLATFORM_ADMIN_FULL_NAME="Platform Administrator" 
export SSRF_PROTECTION_ENABLED=true
export SSRF_BLOCK_PRIVATE_IPS=true
export SSRF_BLOCK_LOCALHOST=true
export SSRF_BLOCK_LINK_LOCAL=true
export SSRF_BLOCK_CLOUD_METADATA=true
export SSRF_ALLOWED_PROTOCOLS=http,https
export SSRF_ALLOWLIST_DOMAINS=""  # Empty = block internal, allow external
export SSRF_BLOCKLIST_DOMAINS="evil.com,malware.net"

MCPGATEWAY_BEARER_TOKEN="$( \
     uvx --from mcp-contextforge-gateway \
     python -m mcpgateway.utils.create_jwt_token \
     --username $PLATFORM_ADMIN_EMAIL --exp 10080 --secret $BASIC_AUTH_PASSWORD \
     )"

TOKEN="$MCPGATEWAY_BEARER_TOKEN"

HEADERS=(
        -H "Authorization: Bearer $MCPGATEWAY_BEARER_TOKEN"
        -H "Content-Type: application/json; charset=utf-8"
        -H "Accept: application/json, application/x-ndjson, text/event-stream"
)




