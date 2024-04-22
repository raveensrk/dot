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

