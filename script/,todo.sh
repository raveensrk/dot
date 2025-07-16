#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

current_file=$(realpath "$0")


vim -c 'vim /\[\ \]\|todo\|fixme/g ~/dot/**/*.md ~/iCloud/notes/**/*.md ~/work/**/*.md | copen'

