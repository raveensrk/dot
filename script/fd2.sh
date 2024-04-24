#!/usr/bin/env bash

fd2() {
	local pattern
	local path
	local cmd
	local dirrs
	local dir
	local code

	read -p "Dir name Pattern   : " -i "."	-re pattern
	read -p "Path               : " -i "$PWD" -re path

	cmd="find ${path/~/\$HOME} -type d \
		| command grep --color '$pattern' \
		| command grep --color -v '\.\w\+\/' \
		| command grep --color -v '\.\w\+$'"
	history -s "$cmd"
	readarray -t dirrs < <(eval "$cmd")

	case "${#dirrs[@]}" in
	0)
		echo "None Found..."
		code=2
		;;
	1)
		code=0
		cd "${dirrs[@]}" || return 2
		;;
	*)
		# shellcheck disable=2048
		select dir in "${dirrs[@]}"; do
			cd "${dir}" || return 2
			break
		done
		code=0
		;;
	esac

	echo "Command: $cmd"
	return "$code"
}
