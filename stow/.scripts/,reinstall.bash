#!/bin/bash

pushd "$MY_REPOS" || exit 2
for f in $(find . -iname install.bash); do
    pushd "$(dirname "$f")" || exit 2
    chmod +x ./install.bash
    ./install.bash
    popd || exit 2
done
popd || exit 2
