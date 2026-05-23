#!/usr/bin/env bash
fd -E Library | fzf | xargs realpath | pbcopy
