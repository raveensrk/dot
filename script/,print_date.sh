#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

while :; do
	sleep 1
	date >> ~/tmp/tmp.txt
done 
