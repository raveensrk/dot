#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

current_file=$(realpath "$0")


wget -nc https://github.com/jgm/pandoc/releases/download/3.3/pandoc-3.3-linux-amd64.tar.gz
tar xvf pandoc-3.3-linux-amd64.tar.gz -C ~/.local/ --strip-components=1
