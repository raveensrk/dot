  cd ~/.tmp
  wget -nc https://ftp.gnu.org/gnu/bash/bash-5.1.tar.gz
  tar xf bash-5.1.tar.gz
  cd bash-5.1
  ./configure --prefix=$HOME/.local
  make
  make install
