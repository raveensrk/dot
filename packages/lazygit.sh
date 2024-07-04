#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

mkdir ~/.tmp
pushd ~/.tmp || exit 2

wget -nc --output-document lazygit.tar.gz 'https://github.com/jesseduffield/lazygit/releases/download/v0.42.0/lazygit_0.42.0_Linux_x86_64.tar.gz'
tar xf lazygit.tar.gz -C ~/.local/bin lazygit

popd
