#!/usr/bin/env bash

green() {
	echo -ne "\e[38;5;2m"
}
declare -fx green

red() {
	echo -ne "\e[38;5;1m"
}
declare -fx red

yellow() {
	echo -ne "\e[38;5;11m"
}
declare -fx yellow
blue() {
	echo -ne "\e[38;5;75m"
}
declare -fx blue

nocolor() {
	echo -ne "\e[0m"
}
declare -fx nocolor

export green="\e[38;5;2m"
export red="\e[38;5;1m"
export yellow="\e[38;5;11m"
export blue="\e[38;5;75m"
export nocolor="\e[0m"
export dull="\e[2m"

echog() {
	echo -ne "\e[38;5;2m" "${@}" "\e[0m\n"
}
export -f echog
echob() {
	echo -ne "$blue" "${@}" "$nocolor\n"
}
export -f echob
echor() {
	echo -ne "$red" "${@}" "$nocolor\n"
}
export -f echor
echoy() {
	echo -ne "$dull" "$yellow" "$@" "$nocolor" "\n"
}
export -f echoy

echod () { 
	echo -ne "\e[3m\e[2m\e[38;5;108m" "$@" "$nocolor" "\n"
}
export -f echod

