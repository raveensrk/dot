#!/usr/bin/env bash

source colors.sh
source require.sh
require_var PROVIDE_REQUIRE
require_var PROVIDE_COLORS

pushd2() {
	command pushd "$1" >/dev/null || {
		echor "Cannon push directory: $1" &&
			return 2
	}
}
export -f pushd2

popd2() {
	command popd >/dev/null || {
		echor "Cannot pop out of directory: $PWD" &&
			return 2
	}
}
export -f popd2

change_to_script_dir() {
	local path
	local dir
	path=$(realpath "$1")
	dir=$(dirname "$path")
	# echo "path = $path"
	# echo "dir = $dir"
	pushd2 "$dir"
}
export -f change_to_script_dir

mkdir2() {
	if [[ ! -d "$1" ]]; then
		command mkdir -p "$1"
	fi
}
export -f mkdir2

rm_mkdir() {
	if [[ ! -d "$1" ]]; then
		echor "rm_mkdir: $1 is not a directory..."
		return 2
	fi
	command rm -rf "$1"
	mkdir2 "$1"
}
export -f rm_mkdir

diff_unit_test() {
	if diff "$1" "$2"; then
		echog "UNIT_TEST: TAR: PASS"
	else
		echor "UNIT_TEST: TAR: FAIL"
		return 2
	fi
}
export -f diff_unit_test

reload2() {
	source "$HOME/.bashrc" || {
		echor "Unable to reload .bashrc" &&
			return 2
	}
}
export -f reload2

export PROVIDE_HEADER=1
