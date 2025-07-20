#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

task $* modify due:tomorrow
,task_due_today.sh
