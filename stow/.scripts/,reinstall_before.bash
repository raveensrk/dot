#!/bin/bash

# pushd ~/my_repos/dotfiles-main
# make update_emacs
# popd

pushd "$MY_REPOS" > /dev/null  || exit 2
for f in $(find . -iname install_before.bash); do
    pushd "$(dirname "$f")" > /dev/null  || exit 2
    chmod +x ./install_before.bash
    ./install_before.bash
    popd > /dev/null  || exit 2
done
popd > /dev/null  || exit 2
