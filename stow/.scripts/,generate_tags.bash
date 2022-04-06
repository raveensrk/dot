#!/bin/bash

pushd "$MY_REPOS" || exit 2
ctags --verbose -R ./*
popd || exit 2
