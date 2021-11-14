#!/bin/bash

if [ ! -d .emacs.d/vendor ]; then
    mkdir .emacs.d/vendor
fi
pushd .emacs.d/vendor
wget https://raw.githubusercontent.com/bbatsov/guru-mode/master/guru-mode.el
popd
 
if [ ! -d .emacs.d/site-lisp ]; then
    mkdir .emacs.d/site-lisp
fi
pushd .emacs.d/site-lisp
git clone git@github.com:magnars/dash.el.git
git clone git@github.com:magit/transient.git
git clone git@github.com:magit/with-editor.git
git clone git@github.com:magit/magit.git
popd

pushd .emacs.d/site-lisp/magit
make
popd



