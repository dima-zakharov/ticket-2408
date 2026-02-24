#!/usr/bin/env -S bash

set -xueo pipefail

source ./00-env.sh


curl -s "http://0.0.0.0:$PORT/resources" "${HEADERS[@]}" | yq -P 




