#!/bin/bash

# pushd ~/my_repos/dotfiles-main
# make update_emacs
# popd

pushd "$MY_REPOS" || exit 2
for f in $(find . -iname install_everything.bash); do
    pushd "$(dirname "$f")" || exit 2
    chmod +x ./install_everything.bash
    ./install_everything.bash
    popd || exit 2
done
popd || exit 2


