#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

osascript -e "set the clipboard to POSIX file \"$(realpath "$1")\""
