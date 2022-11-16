pushd ~/.tmp
wget -nc https://www.kernel.org/pub/software/scm/git/git-2.38.1.tar.gz
tar xf git-2.38.1.tar.gz
pushd git-2.38.1
./configure --prefix=$$HOME/.local
make -j
make install
popd
popd
