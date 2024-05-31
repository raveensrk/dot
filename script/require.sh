#!/usr/bin/env bash

# echo "${BASH_VERSINFO[@]}"

check_bash_version () {
	if [[ "${BASH_VERSINFO[0]}" -ge 5 ]]; then
		echog "Bash version = ${BASH_VERSINFO[0]} supported"
	else
		echor "Bash version = ${BASH_VERSINFO[0]} not supported"
		return 2
	fi
}

declare -xf check_bash_version


require_var() {
	if grep -q "^${1}=.*" <(env); then
		echor "Exists: ${!1}"
		return 2
	fi
}
declare -xf require_var

require_file() {
	echoy "Checking if file $1 exists"
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
		return 2
	else
		echog "yes"
	fi
}
declare -xf require_file

require_dir() {
	echoy "Checking if directory $1 exists"
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
		return 2
	else
		echog "yes"
	fi
}
declare -xf require_dir

require_cmd() {
	echoy "Checking if command $1 exists"
	if ! type -t "$1"; then
		echor "Require Dir: $1 does not exist."
		return 2
	else
		echog "yes"
	fi
}
declare -xf require_cmd

source_if_exists(){
	if [[ -f "$1" ]]; then
		# shellcheck disable=1090
		source "$1"
	fi
}
declare -xf source_if_exists

