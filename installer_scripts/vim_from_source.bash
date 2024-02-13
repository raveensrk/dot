#!/bin/bash 

echo "Are you in default bash shell with --norc and --noprofile? Press any key to continue. ^c to exit."
read 

pushd ~/.tmp || exit 2

wget -nc https://github.com/vim/vim/archive/refs/tags/v9.1.0098.tar.gz
[ ! -d "vim-9.1.0098" ] && tar xf v9.1.0098.tar.gz
pushd vim-9.1.0098 || exit 2
echo -e "${BLUE}Do you want to Install with x? [Y/n]:${NC}"
read -r choice
make clean
if [ "$choice" = "Y" ]; then 
    if [[ $(uname -a | awk '{print $1}') = "Darwin" ]]; then
        ./configure \
            --prefix=$HOME/.local \
            --with-features=huge \
            --enable-gui=yes \
            --enable-python3interp
    else
        # ./configure --prefix="$HOME/.local" --with-features=huge --with-x  --enable-gui=auto --enable-xim --enable-fontset  --enable-python3interp --enable-multibyte --enable-gtk3-check
        ./configure \
            --prefix=$HOME/.local \
            --with-features=huge \
            --with-x  \
            --enable-gui=auto \
            --enable-python3interp
    fi
else
    ./configure \
        --prefix=$HOME/.local \
        --with-features=huge \
        --disable-gui \
        --without-x  \
        --enable-python3interp 
fi 
python3 -m pip install --upgrade pip
python3 -m pip install --user pynvim
make -j
make install
popd || exit 2
popd || exit 2
exit 0

