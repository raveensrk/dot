#!/usr/bin/env bash

# echo "${BASH_VERSINFO[@]}"

unset check_bash_version
check_bash_version () {
	if [[ "$BASH_VERSINFO" -le 5 ]]; then
		echor "Unsopported bash version = $BASH_VERSINFO"
		return 2
	fi
}
export -f check_bash_version


unset require_var
require_var() {
	if [[ "$1" -ne 1 ]]; then
		echor "Require var: $1 != 1"
		return 2
	fi
}
export -f require_var

unset require_file
require_file() {
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
		return 2
	fi
}
export -f require_file

unset require_dir
require_dir() {
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
		return 2
	fi
}
export -f require_dir

export PROVIDE_REQUIRE=1
