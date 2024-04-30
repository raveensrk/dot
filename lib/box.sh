#!/usr/bin/env bash

box() {
	# set -euo pipefail
	# set -n
	# IFS=$'\n\t'
	# set -x

	if [ "$#" -eq 0 ]; then
		read -re line
		text="$line"
	else
		text="$*"
	fi

	len="${#text}"
	len=$((len + 4))

	# printf "\t\t"
	# {
	# 	printjot -b - "$len" | rs -w200 -g 0
	# 	printf "%s\n" "$text"
	# 	jot -b - "$len" | rs -w200 -g 0
	# } | lolcat

	{
		print_centered - -
		print_centered "$text"
		print_centered - -
	} | lolcat
}
declare -xf box
