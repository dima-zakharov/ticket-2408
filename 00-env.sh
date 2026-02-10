#!/usr/bin/env -S bash

set -ueo pipefail

PORT=${PORT:=4444}

# Quick start with environment variables
BASIC_AUTH_PASSWORD=pass \
MCPGATEWAY_UI_ENABLED=true \
MCPGATEWAY_ADMIN_API_ENABLED=true \
PLATFORM_ADMIN_EMAIL=admin@example.com \
PLATFORM_ADMIN_PASSWORD=changeme \
PLATFORM_ADMIN_FULL_NAME="Platform Administrator" \

MCPGATEWAY_BEARER_TOKEN="$( \
     uvx --from mcp-contextforge-gateway \
     python -m mcpgateway.utils.create_jwt_token \
     --username $PLATFORM_ADMIN_EMAIL --exp 10080 --secret $BASIC_AUTH_PASSWORD \
     )"

HEADERS=(
        -H "Authorization: Bearer $MCPGATEWAY_BEARER_TOKEN"
        -H "Content-Type: application/json; charset=utf-8"
        -H "Accept: application/json, application/x-ndjson, text/event-stream"
)


