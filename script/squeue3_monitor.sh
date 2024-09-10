#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

while true; do
	sleep 1
	clear
	squeue -u "$USER" -o "%.5i %.10P %.60j %.8u %.2t %.10M %.20V %.20e %.6D %.30R %.20B %r %R"
done
