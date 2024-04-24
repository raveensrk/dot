#!/usr/bin/env bash

# echo "${BASH_VERSINFO[@]}"

unset check_bash_version
check_bash_version () {
	printf "${blue}Checking if bash version is greater than or equal to 5...${nocolor}"
	if [[ "${BASH_VERSINFO[0]}" -ge 5 ]]; then
		printf "${green}yes${nocolor}...${BASH_VERSINFO[0]} supported...\n"
	else
		printf "${red}no${nocolor}...${BASH_VERSINFO[0]} unsupported...\n"
		return 2
	fi
}
export -f check_bash_version


unset require_var
require_var() {
	printf "${blue}Checking if var $1 exists...${nocolor}"
	if grep -q "^${1}=.*" <(env); then
		printf "${red}yes${nocolor}...${!1}\n"
		return 2
	else
		printf "no\n"
	fi
}
export -f require_var

unset require_file
require_file() {
	printf "${blue}Checking if file $1 exists...${nocolor}"
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
		return 2
	else
		printf "yes\n"
	fi
}
export -f require_file

unset require_dir
require_dir() {
	printf "${blue}Checking if directory $1 exists...${nocolor}"
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
		return 2
	else
		printf "yes\n"
	fi
}
export -f require_dir

unset require_cmd
require_cmd() {
	printf "${blue}Checking if command $1 exists...${nocolor}"
	if ! type -t "$1"; then
		echor "Require Dir: $1 does not exist."
		return 2
	else
		printf "${green}yes${nocolor}...\n"
	fi
}
export -f require_cmd
