5#!/usr/bin/env -S bash

set -xueo pipefail

source ./00-env.sh

# Test AWS metadata endpoint blocking (TC-SSRF-001)
echo "Testing AWS metadata endpoints..."

# User data endpoint
curl -s -w "\nStatus: %{http_code}\n" \
  -X POST "${HEADERS[@]}" \
  -d '{"resource":{"uri":"http://www.listru.site","name":"listru","description":"listru","content":"test"}}' \
  "http://0.0.0.0:$PORT/resources"
