#!/usr/bin/env bash

if ! emacsclient -e "(daemonp)"; then
    emacs --daemon
fi
