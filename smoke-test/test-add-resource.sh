5#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh

curl -s -w "\nStatus: %{http_code}\n" \
	-X POST "${HEADERS[@]}" \
	-d '{"resource":{"uri":"http://www.listru.site","name":"listru","description":"listru","content":"test"}}' \
	"http://0.0.0.0:$PORT/resources"
