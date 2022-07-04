#!/opt/homebrew/bin/bash

if ! command -v brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install $(xargs < ./packages_list_osx.txt)
