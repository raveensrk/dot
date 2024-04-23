#!/usr/bin/env bash

provide() {
	declare provide_var_name=provide_$1
	declare provide_var_value=1
	declare -g $provide_var_name=$provide_var_value
	# echob "Provide Var: set:  $provide_var_name=$provide_var_value"
}
export -f provide

require() {
	declare provide_var_name=provide_$1
	echob "Require Var: Checking if $provide_var_name is set..."
	if [[ -v ${provide_var_name} ]]; then
		echog "Require var: $provide_var_name is set."
		if [[ -z ${!provide_var_name} ]]; then
			echor "Require var: $provide_var_name is set but empty..."
			return 2
		else
			declare provide_var_value=${!provide_var_name}
			echog "Require var: $provide_var_name = $provide_var_value"
		fi
	else
		echor "Require var: $provide_var_name is unset."
		return 2
	fi
}
export -f require

require_file() {
	if [[ ! -f "$1" ]]; then
		echor "Require File: $1 does not exist."
		return 2
	fi
}
export -f require_file

require_dir() {
	if [[ ! -d "$1" ]]; then
		echor "Require Dir: $1 does not exist."
		return 2
	fi
}
export -f require_dir

provide require
