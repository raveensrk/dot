#!/usr/bin/env bash

source colors.sh

header() {
	string="${blue}Starting:$(realpath "$1")${nocolor}\n"
	printf "%b" "$string"
}

footer() {
	string="${green}Done${nocolor}\n"
	printf "%b" "$string"
}

change_to_script_dir() {
	local path
	local dir
	path=$(realpath "$1")
	dir=$(dirname "$path")
	echo "path = $path"
	echo "dir = $dir"
	pushd "$dir" || {
		echo "ERROR! Cannot change dir = $dir" &&
			exit 2
	}
}

mkdir2() {
	if [[ ! -d "$1" ]]; then
		mkdir -vp "$1"
	else
		echo "$1" exists, Not creating directory...
	fi
}

rm_mkdir() {
	rm -rf "$1"
	mkdir "$1"
}

pushd2() {
	pushd "$1" >/dev/null || return 2
}
export -f pushd2

popd2() {
	popd >/dev/null || return 2
}
export -f popd2

export -f header footer mkdir2 rm_mkdir change_to_script_dir

require_file() {
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
	fi
}
export -f require_file
require_dir() {
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
	fi
}
export -f require_dir

diff_unit_test() {
	if diff "$1" "$2"; then
		echog "UNIT_TEST: TAR: PASS"
	else
		echor "UNIT_TEST: TAR: FAIL"
	fi
}
export -f diff_unit_test
