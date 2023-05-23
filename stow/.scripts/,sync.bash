#!/bin/bash 

,reinstall_before.bash
,sync_all_repos.bash "$MY_REPOS"
,reinstall.bash 

# if [ "$USER@$HOSTNAME" = "raveen@UhIN-LT-142" ]; then
#     ,sync_all_repos.bash "/mnt/c/Github"
# fi 
