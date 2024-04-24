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

blink="\e[5m"
blue="\e[38;5;75m"
bold="\e[1m"
cyan="\e[36m"
dim="\e[2m"
green="\e[38;5;2m"
hidden="\e[8m"
inverse="\e[7m"
italic="\e[3m"
magenta="\e[35m"
nocolor="\e[0m"
red="\e[38;5;1m"
strikethrough="\e[9m"
underline="\e[4m"
yellow="\e[38;5;11m"

echog() {
	echo -ne "\e[38;5;2m" "${@}" "\e[0m\n"
}
echob() {
	echo -ne "$blue" "${@}" "$nocolor\n"
}
echor() {
	echo -ne "$red" "${@}" "$nocolor\n"
}
echoy() {
	echo -ne "$dim" "$yellow" "$@" "$nocolor" "\n"
}

echod () { 
	echo -ne "\e[3m\e[2m\e[38;5;108m" "$@" "$nocolor" "\n"
}
