#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

cat <<-HERE | xargs pip install
trash-cli
trash
rich
pytest
scipy
numpy
black
shtab
HERE
