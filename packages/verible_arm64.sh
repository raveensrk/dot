#!/usr/bin/env bash
pushd ~/tmp
wget -nc https://github.com/chipsalliance/verible/releases/download/v0.0-4023-gc1271a00/verible-v0.0-4023-gc1271a00-linux-static-arm64.tar.gz
tar xf verible-v0.0-4023-gc1271a00-linux-static-arm64.tar.gz
cp -arf verible-v0.0-4023-gc1271a00/bin/* ~/.local/bin
ls -l ~/.local/bin
echo INSTALLED
popd


