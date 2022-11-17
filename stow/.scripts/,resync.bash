#!/bin/bash


pushd "$MY_REPOS" || exit 2
for f in $(find . -iname sync.bash); do
    pushd "$(dirname "$f")" || exit 2
    chmod +x ./sync.bash
    ./sync.bash
    popd || exit 2
done
popd || exit 2


