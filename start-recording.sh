#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh

npx playwright codegen \
	--load-storage=$HOME/.local/ticket-2408-auth.json \
	http://localhost:4444/admin
