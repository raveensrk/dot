#!/bin/bash 

echo "Are you in default bash shell with --norc and --noprofile? Press any key to continue. ^c to exit."
read 

pushd ~/.tmp || exit 2

# wget -nc https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
# tar xf vim-8.2.tar.bz2
# pushd vim82 || exit 2
# Get vim 9 from git
# git clone git@github.com:vim/vim.git
wget -nc https://github.com/vim/vim/archive/refs/tags/v9.0.1539.tar.gz
tar xf v9.0.1539.tar.gz
pushd vim-9.0.1539 || exit 2
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
                        --enable-gui=gtk3 \
                        --enable-python3interp \
                        --enable-gtk3-check
    fi
else
    ./configure \
        --prefix=$HOME/.local \
        --disable-gui \
        --without-x  \
        --enable-python3interp 
fi 
python3 -m pip install --upgrade pip
python3 -m pip install --user pynvim
make
make install
popd || exit 2
popd || exit 2
exit 0

