pushd ~/.tmp || return 2
wget -nc "https://github.com/astrand/xclip/archive/refs/tags/0.13.tar.gz"
tar xvf 0.13.tar.gz
pushd xclip-0.13 || return 2
autoreconf
./configure --prefix="$HOME/.local"
make
make install
popd || return 2
popd || return 2
