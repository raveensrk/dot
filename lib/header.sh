#!/usr/bin/env bash

set -a

source colors.sh
source require.sh
source box.sh

pushd2() {
	command pushd "$1" >/dev/null || {
		echor "Cannon push directory: $1" &&
			return 2
	}
}

popd2() {
	command popd >/dev/null || {
		echor "Cannot pop out of directory: $PWD" &&
			return 2
	}
}

change_to_script_dir() {
	local path
	local dir
	path=$(realpath "$1")
	dir=$(dirname "$path")
	# echo "path = $path"
	# echo "dir = $dir"
	pushd2 "$dir"
}

mkdir2() {
	if [[ ! -d "$1" ]]; then
		command mkdir -p "$1"
	fi
}

rm_mkdir() {
	if [[ ! -d "$1" ]]; then
		echor "rm_mkdir: $1 is not a directory..."
		return 2
	fi
	command rm -rf "$1"
	mkdir2 "$1"
}

diff_unit_test() {
	name="$3"
	if diff "$1" "$2"; then
		echog "UNIT_TEST: $name:  PASS"
	else
		echor "UNIT_TEST: $name:  FAIL"
		return 2
	fi
}

reload2() {
	source "$HOME/.bashrc" || {
		echor "Unable to reload .bashrc" &&
			return 2
	}
}
set +a
