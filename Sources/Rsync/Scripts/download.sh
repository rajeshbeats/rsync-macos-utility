#!/usr/bin/env bash

#  check-connection.sh
#  SvijaSync
#
#  Created by Rajesh Ramachandrakurup on 6/2/21.
#  

remote_connection="$1"
password="$2"
success="$3"

exclusions=(
    --exclude ".swp"
    --exclude ".git"
    --exclude ".command"
    --exclude ".pwd"
)

export RSYNC_PASSWORD=$password
rsync -azq --delete "${exclusions[@]}" "$remote_connection" "sync/" && echo "$success"
RSYNC_PASSWORD=
