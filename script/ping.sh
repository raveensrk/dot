#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

current_file=$(realpath "$0")

help() {
	cat <<-HERE
		Usage
		-----------------
	HERE
	exit 0
}

while [ "$#" -ne 0 ]; do
	case "$1" in
	--help | -h)
		help
		;;
	*)
		echor "Unknown Argument: $1 while running $current_file!"
		exit 2
		;;
	esac
done

ping "www.google.com"
