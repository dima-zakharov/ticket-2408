5#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh


# User data endpoint
curl -v -w "\nStatus: %{http_code}\n" \
	"${HEADERS[@]}" \
	"http://0.0.0.0:$PORT/health"
