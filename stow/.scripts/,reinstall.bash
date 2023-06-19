#!/bin/bash

pushd "$MY_REPOS" > /dev/null  || exit 2
for f in $(find . -iname install_everything.bash); do
    pushd "$(dirname "$f")" > /dev/null  || exit 2
    chmod +x ./install_everything.bash
    ./install_everything.bash
    popd > /dev/null  || exit 2
done
popd > /dev/null  || exit 2


