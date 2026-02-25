5#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh

curl -s -w "\nStatus: %{http_code}\n" \
	-X GET "${HEADERS[@]}" \
	"http://0.0.0.0:$PORT/health"
