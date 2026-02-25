#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh

echo $BASE_URL
bru --verbose --noproxy --env-var BASE_URL=$BASE_URL --env-var TOKEN=$TOKEN --reporter-html results.html \
    run health.yml
    
# bru run health.yml --env-var BASE_URL=$BASE_URL --env-var TOKEN=$TOKE