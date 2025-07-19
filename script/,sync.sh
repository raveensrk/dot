#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'


fd . $HOME --exact-depth 1 -p | grep dot | xargs -n 1 lazygit -p
