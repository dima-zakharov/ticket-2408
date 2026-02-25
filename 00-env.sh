#!/usr/bin/env -S bash

set -ueo pipefail

export PORT=${PORT:=4444}
export BASE_URL=http://localhost:$PORT

# env vars
export BASIC_AUTH_PASSWORD="$(tr -d '\r\n' < ~/.local/ticket-2408-pass)"
export JWT_SECRET_KEY=$BASIC_AUTH_PASSWORD
export MCPGATEWAY_UI_ENABLED=true
export MCPGATEWAY_ADMIN_API_ENABLED=true
export PLATFORM_ADMIN_EMAIL=admin@example.com
export PLATFORM_ADMIN_PASSWORD=changeme
export PLATFORM_ADMIN_FULL_NAME="Platform Administrator"
export SSRF_PROTECTION_ENABLED=true
export SSRF_BLOCKED_NETWORKS='["169.254.169.254/32","169.254.169.123/32","fd00::1/128","169.254.0.0/16","fe80::/10"]'
export SSRF_BLOCKED_HOSTS='["metadata.google.internal","metadata.internal"]'
export SSRF_ALLOW_LOCALHOST=false
export SSRF_ALLOW_PRIVATE_NETWORKS=false
export SSRF_ALLOWED_NETWORKS='["10.20.0.0/16","192.168.50.0/24"]'
export SSRF_DNS_FAIL_CLOSED=true

export PYTHONWARNINGS="ignore"
export LOG_LEVEL="ERROR"
export MCPGATEWAY_BEARER_TOKEN="$(
		uv run python -m mcpgateway.utils.create_jwt_token \
		--username $PLATFORM_ADMIN_EMAIL \
		--exp 10080 --secret $BASIC_AUTH_PASSWORD \
		2>/dev/null  \
)"

export TOKEN="$MCPGATEWAY_BEARER_TOKEN"
echo $TOKEN > .token

export HEADERS=(
	-H "Authorization: Bearer $MCPGATEWAY_BEARER_TOKEN"
	-H "Content-Type: application/json; charset=utf-8"
	-H "Accept: application/json, application/x-ndjson, text/event-stream"
)
