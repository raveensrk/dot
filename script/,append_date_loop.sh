#!/usr/bin/env bash
# Print the date every second to stdout and append it to ~/tmp/tmp.txt.
#
# Usage: ,append_date_loop.sh [-h|--help|help]
# Runs until Ctrl-C. Announces the output file on stderr before starting.
# Example: ,append_date_loop.sh

case "${1:-}" in -h|--help) sed -n '2s/^# \{0,1\}//p' "$0"; exit 0;; help) sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 0;; esac

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

out=~/tmp/tmp.txt
echo "Appending date every second to stdout and $out (Ctrl-C to stop)" >&2

while :; do
	sleep 1
	date | tee -a "$out"
done 
