  STOW_VERSION=stow-2.2.0
  cd ~/.tmp
  wget -nc https://ftp.gnu.org/gnu/stow/${STOW_VERSION}.tar.gz
  tar xf ${STOW_VERSION}.tar.gz
  cd ~/.tmp/${STOW_VERSION}
  ./configure --prefix=$$HOME/.local
  make
  make install
