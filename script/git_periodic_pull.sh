#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
# set -x

while true; do
	git pull > /dev/null 2>&1 
	sleep 5
done
