#!/usr/bin/env bash

green() {
	echo -ne "\e[38;5;2m"
}
declare -xf green

red() {
	echo -ne "\e[38;5;1m"
}
declare -xf red

yellow() {
	echo -ne "\e[38;5;11m"
}
declare -xf yellow
blue() {
	echo -ne "\e[38;5;75m"
}
declare -xf blue

nocolor() {
	echo -ne "\e[0m"
}
declare -xf nocolor

declare -x blink="\e[5m"
declare -x blue="\e[38;5;75m"
declare -x bold="\e[1m"
declare -x cyan="\e[36m"
declare -x dim="\e[2m"
declare -x green="\e[38;5;2m"
declare -x hidden="\e[8m"
declare -x inverse="\e[7m"
declare -x italic="\e[3m"
declare -x magenta="\e[35m"
declare -x nocolor="\e[0m"
declare -x red="\e[38;5;1m"
declare -x strikethrough="\e[9m"
declare -x underline="\e[4m"
declare -x yellow="\e[38;5;11m"

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

declare -xf echog echob echor echoy echod
