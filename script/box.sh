#!/usr/bin/env bash

box() {
	if [ "$#" -eq 0 ]; then
		read -re line
		text="$line"
	else
		text="$*"
	fi

	len="${#text}"

	printf "╭─"
	for ((i=0; i<len; i++)); do
		printf "─"
	done
	printf "─╮\n"

	printf "│ %s │\n" "$text"

	printf "╰─"
	for ((i=0; i<len; i++)); do
		printf "─"
	done
	printf "─╯\n"
}
