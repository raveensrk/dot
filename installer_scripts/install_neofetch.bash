#!/usr/bin/env bash

pushd ~/tmp
git clone https://github.com/dylanaraps/neofetch
pushd neofetch
cp neofetch ~/.local/bin
chmod +x ~/.local/bin/neofetch
popd
popd
