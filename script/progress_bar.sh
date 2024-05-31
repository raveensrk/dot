#!/usr/bin/env bash

set -euo pipefail
# set -x
IFS=$'\n\t'

source header.sh

require_file "$runtime"
echob "$progress_name"


# exit 0

current_time=$SECONDS
circles=("◐" "◓" "◑" "◒")

dots=(
	"⢀ "
	"⡀ "
	"⠄ "
	"⢂ "
	"⡂ "
	"⠅ "
	"⢃ "
	"⡃ "
	"⠍ "
	"⢋ "
	"⡋ "
	"⠍⠁"
	"⢋⠁"
	"⡋⠁"
	"⠍⠉"
	"⠋⠉"
	"⠋⠉"
	"⠉⠙"
	"⠉⠙"
	"⠉⠩"
	"⠈⢙"
	"⠈⡙"
	"⢈⠩"
	"⡀⢙"
	"⠄⡙"
	"⢂⠩"
	"⡂⢘"
	"⠅⡘"
	"⢃⠨"
	"⡃⢐"
	"⠍⡐"
	"⢋⠠"
	"⡋⢀"
	"⠍⡁"
	"⢋⠁"
	"⡋⠁"
	"⠍⠉"
	"⠋⠉"
	"⠋⠉"
	"⠉⠙"
	"⠉⠙"
	"⠉⠩"
	"⠈⢙"
	"⠈⡙"
	"⠈⠩"
	"⠀⢙"
	"⠀⡙"
	"⠀⠩"
	"⠀⢘"
	"⠀⡘"
	"⠀⠨"
	"⠀⢐"
	"⠀⡐"
	"⠀⠠"
	"⠀⢀"
	"⠀⡀"
)

echo ""
length="${#dots[@]}"
circles_length="${#circles[@]}"
# count=$length
count=0
circles_count=0
finish_time=$(<"$runtime")

while [[ $current_time -lt $finish_time ]]; do
	current_time=$SECONDS
	remaining_time_in_sec=$((finish_time - current_time))
	remaining_time=$((remaining_time_in_sec / 60))
	progress=$((current_time * 100 / finish_time))
	progress_gap=$((100 - progress))
	progress=$((progress / 2))
	progress_gap=$((progress_gap / 2))
	remaining_gap=$((50 - progress_gap - progress)) # Could have used mod %
	progress_gap=$((progress_gap + remaining_gap))

	echo -en "\e[1A\e[0G\e[2K"
	count=$((count + 1))
	[[ $count -eq $((length - 1)) ]] && count=0
	circles_count=$((circles_count + 1))
	[[ $circles_count -eq $((circles_length - 1)) ]] && circles_count=0
	echo -en "${dots[$count]}"
	echo -en "\e[38;5;2m"
	for ((i = 0; i < progress; i++)); do
		echo -en "="
	done
	echo -en ">\e[38;5;3m"
	echo -n "${circles[$circles_count]}"
	echo -en "\e[0m"
	for ((i = 0; i < progress_gap; i++)); do
		echo -en "-"
	done
	echo "|$((progress * 2))%|$remaining_time mins|${remaining_time_in_sec} sec|"

	sleep 0.05
done

exit 0
