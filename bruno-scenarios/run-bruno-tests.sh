#!/usr/bin/env -S bash

set -xueo pipefail

source $(dirname $(readlink -f $0))/../00-env.sh

echo $BASE_URL
bru --verbose --noproxy \
	--env-var BASE_URL=$BASE_URL \
	--env-var TOKEN=$TOKEN \
	--reporter-html results.html \
	--csv-file-path data.csv \
	run .
