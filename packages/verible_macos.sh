#!/usr/bin/env bash
pushd ~/tmp
wget -nc https://github.com/chipsalliance/verible/releases/download/v0.0-3752-g8b64887e/verible-v0.0-3752-g8b64887e-macOS.tar.gz
tar xf	verible-v0.0-3752-g8b64887e-macOS.tar.gz
mkdir -p ~/.local/bin
cp -arf verible-v0.0-3584-g8b64887e-macOS/bin/* ~/.local/bin
ls -l ~/.local/bin
echo INSTALLED
popd


