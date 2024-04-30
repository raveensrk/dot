#!/usr/bin/env bash

# echo "${BASH_VERSINFO[@]}"

check_bash_version () {
	printf "${blue}Checking if bash version is greater than or equal to 5...${nocolor}"
	if [[ "${BASH_VERSINFO[0]}" -ge 5 ]]; then
		printf "${green}yes${nocolor}...${BASH_VERSINFO[0]} supported...\n"
	else
		printf "${red}no${nocolor}...${BASH_VERSINFO[0]} unsupported...\n"
		return 2
	fi
}

declare -xf check_bash_version


require_var() {
	printf "${blue}Checking if var $1 exists...${nocolor}"
	if grep -q "^${1}=.*" <(env); then
		printf "${red}yes${nocolor}...${!1}\n"
		return 2
	else
		printf "no\n"
	fi
}
declare -xf require_var

require_file() {
	printf "${blue}Checking if file $1 exists...${nocolor}"
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
		return 2
	else
		printf "yes\n"
	fi
}
declare -xf require_file

require_dir() {
	printf "${blue}Checking if directory $1 exists...${nocolor}"
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
		return 2
	else
		printf "yes\n"
	fi
}
declare -xf require_dir

require_cmd() {
	printf "${blue}Checking if command $1 exists...${nocolor}"
	if ! type -t "$1"; then
		echor "Require Dir: $1 does not exist."
		return 2
	else
		printf "${green}yes${nocolor}...\n"
	fi
}
declare -xf require_cmd

source_if_exists(){
	if [[ -f "$1" ]]; then
		source "$1"
	fi
}
declare -xf source_if_exists

