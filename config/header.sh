#!/usr/bin/env bash

source colors.sh

pushd2() {
	command pushd "$1" >/dev/null || echor "Cannon push directory: $1"
}
export -f pushd2

popd2() {
	command popd >/dev/null || echor "Cannot pop out of directory: $PWD"
}
export -f popd2

change_to_script_dir() {
	local path
	local dir
	path=$(realpath "$1")
	dir=$(dirname "$path")
	# echo "path = $path"
	# echo "dir = $dir"
	pushd2 "$dir" || echor "Unable to run pushd2 on dir = $dir"
}
export -f change_to_script_dir

mkdir2() {
	if [[ ! -d "$1" ]]; then
		command mkdir -p "$1"
	fi
}
export -f mkdir2

rm_mkdir() {
	command rm -rf "$1"
	mkdir2 "$1"
}
export -f rm_mkdir

require_file() {
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
		exit 2
	fi
}
export -f require_file

require_dir() {
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
		exit 2
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

reload() {
	source "$HOME/.bashrc" || echor "Unable to reload .bashrc"
}
export -f reload
