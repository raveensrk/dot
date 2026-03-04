#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'


mkdir ~/tmp || true
pushd ~/tmp || exit 2
wget -nc --output-document newsboat.tar.xz https://newsboat.org/releases/2.41/newsboat-2.41.tar.xz
tar xf newsboat.tar.xz
pushd newsboat-2.41
echo "TODO: newsboat build script not complete."
## ./configure --prefix="$HOME/.local"
popd
popd
