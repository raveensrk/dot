#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'


vim -c "vimgrep /$1/ $2/**"
