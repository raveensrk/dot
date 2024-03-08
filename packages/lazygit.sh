#!/bin/bash 

pushd ~/.tmp

wget -nc --output-document lazygit.tar.gz 'https://github.com/jesseduffield/lazygit/releases/download/v0.36.0/lazygit_0.36.0_Linux_x86_64.tar.gz'
tar xf lazygit.tar.gz -C ~/.local/bin lazygit

popd
