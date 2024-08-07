#!/usr/bin/env bash

source "$DOT/script/colors.sh"
source "$DOT/script/require.sh"
source "$DOT/script/box.sh"

pushd2() {
	if [[ ! -d "$1" ]]; then
		echor "Not a directory: $1"
		return 2
	fi

	if command pushd "$1" > /dev/null; then
		echoy "Changing to directory: $1"
	else
		echor "Cannot push directory: $1"
		return 2
	fi
}
declare -xf pushd2

popd2() {
	if command popd >/dev/null; then
		echoy "Popped Out of directory. Current Directory: $PWD"
	else
		echor "Cannot pop out of directory: $PWD"
		return 2
	fi
}
declare -xf popd2

change_to_script_dir() {
	local path
	local dir
	path=$(realpath "$1")
	dir=$(dirname "$path")
	# echo "path = $path"
	# echo "dir = $dir"
	pushd2 "$dir"
}
declare -xf change_to_script_dir

mkdirf() {
	dir="$(dirname "$1")"
	echoy "Making directory: $dir"
	command mkdir -p "$dir"
}
declare -xf mkdirf

mkdir2() {
	dir="$1"
	if [[ ! -d "$dir" ]]; then
		echoy "Making directory: $dir"
		command mkdir -p "$dir"
	fi
}
declare -xf mkdir2

rm_mkdir() {
	echo "Following command will deleted the following directory: $1"
	echo "Press any key twice to approve..."
	read -r
	read -r
	if [[ -d "$1" ]]; then
		chmod -R 777 "$1"
		command rm -rf "$1"
		echoy "Deleting directory: $1"
	fi
	mkdir2 "$1"
}
declare -xf rm_mkdir

diff_unit_test() {
	name="$3"
	if diff "$1" "$2"; then
		echog "UNIT_TEST: $name:  PASS"
	else
		echor "UNIT_TEST: $name:  FAIL"
		return 2
	fi
}
declare -xf diff_unit_test

reload2() {
	source "$HOME/.bashrc" || {
		echor "Unable to reload .bashrc" &&
			return 2
	}
}
declare -xf reload2

