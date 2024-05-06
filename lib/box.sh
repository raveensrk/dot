#!/usr/bin/env bash

# box() {
# 	if [ "$#" -eq 0 ]; then
# 		read -re line
# 		text="$line"
# 	else
# 		text="$*"
# 	fi
#
# 	len="${#text}"
# 	len=$((len + 4))
#
# 	print_centered - -
# 	print_centered "$text"
# 	print_centered - -
# }
#
# declare -xf box
box() {
	if [ "$#" -eq 0 ]; then
		read -re line
		text="$line"
	else
		text="$*"
	fi
	echo -e "STAGE: $magenta$text$nocolor"
}
declare -xf box
