#!/bin/bash

set -e -u

. test.env

hosts=""

# IPs of the test nodes.
for p in $PREFIX $PREFIX2 $PREFIX3; do
    ip=$(echo "$p" | perl -ne 'print "$1\n" if m/\w+@([0-9.]+)$/;')
    hosts="$hosts $ip"
done
# IP of the KV server.
ip=$(echo $KV_ADDR | perl -ne 'print "$1\n" if m/([0-9.]+)(:\d+)?$/;')
hosts="$hosts $ip"

# Formatting OCD.
hosts="$(echo "$hosts" | tr -s ':space:')"

echo "Hosts: $hosts"
for h in $hosts; do
    echo "Checking $h"
    if nc -zv -G3 "$h" 22; then
        echo "** Shutting down $h"
        ssh "root@$h" poweroff || true
    else
        echo "-- Skipping $h"
    fi
done

droplet_ids=""
if [ -z "$DO_TAG" ]; then
    echo "\$DO_TAG is not set, skipping Droplet deletion"
else
    echo "Deleting DO hosts tagged '$DO_TAG'"
    droplet_ids="$(doctl compute droplet list -o json | jq "[.[] | select(.tags[] | contains(\"${DO_TAG}\"))] | .[] .id")"
fi

for d in $droplet_ids; do
    echo "Delete droplet $d"
    doctl compute droplet delete -f "$d"
done
