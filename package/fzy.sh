#!/usr/bin/env bash

set -e

cat <<HERE
curl -L https://github.com/jhawthorn/fzy/releases/download/1.0/fzy-1.0.tar.gz --output "fzy-1.0.tar.gz"
tar xf "fzy-1.0.tar.gz"
cd "fzy-1.0" || echo error && exit 2
PREFIX="$HOME/.local" make
PREFIX="$HOME/.local" make install
HERE
