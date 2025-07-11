#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'



while read line; do
	echo "
	------------------------------------------------------------------------------
	Opening lazygit for $line
	------------------------------------------------------------------------------   
	"
	lazygit -p "$line" 

done < "$HOME/dot_common/list_of_repositories.txt"

