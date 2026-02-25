#!/usr/bin/env -S bash

set -ueo pipefail

source ./00-env.sh

bru run ./bruno-scenarios --env-var BASE_URL=$BASE_URL --env-var TOKEN=$TOKEN

