#!/usr/bin/env bash

green() {
	echo -ne "\e[38;5;2m"
}

red() {
	echo -ne "\e[38;5;1m"
}

yellow() {
	echo -ne "\e[38;5;11m"
}

blue() {
	echo -ne "\e[38;5;75m"
}

nocolor() {
	echo -ne "\e[0m"
}

green="\e[38;5;2m"
red="\e[38;5;1m"
yellow="\e[38;5;11m"
blue="\e[38;5;75m"
nocolor="\e[0m"
echog() {
	echo -ne "\e[38;5;2m${*}\e[0m\n"
}
echob() {
	echo -ne "$blue${*}$nocolor\n"
}
echor() {
	echo -ne "$red${*}$nocolor\n"
	exit 2
}
export green red yellow blue nocolor
export -f green red yellow blue nocolor echog echob echor
