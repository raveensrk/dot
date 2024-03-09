#!/usr/bin/env bash
pushd ~/tmp
wget -nc https://github.com/chipsalliance/verible/releases/download/v0.0-3584-g8d7ea9b4/verible-v0.0-3584-g8d7ea9b4-linux-static-x86_64.tar.gz
tar xf verible-v0.0-3584-g8d7ea9b4-linux-static-x86_64.tar.gz
cp -arf verible-v0.0-3584-g8d7ea9b4/bin/* ~/.local/bin
ls -l ~/.local/bin
echo INSTALLED
popd


