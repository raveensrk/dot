#!/usr/bin/env bash

set -euo pipefail
# set -x
IFS=$'\n\t'

mkdir2 observed

tar --totals --verbose -c --auto-compress --file  observed/compressed.tar.gz  --strip-components 6 /Users/raveenkumarwork/dot/unit_test/tar/some/*

tar -tvf  observed/compressed.tar.gz > observed/compressed_table.txt
tar -tvf  expected/compressed.tar.gz > expected/compressed_table.txt

diff_unit_test observed/compressed_table.txt expected/compressed_table.txt
