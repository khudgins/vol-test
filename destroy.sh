#!/bin/bash

set -e -u

tag="vol-test${BUILD:+-$BUILD}"
consul_vm_tag=$tag-"consul"

. test.env


function shutdown()
{
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
hosts="$(echo $hosts | tr -s ':space:')"

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
}

function destroy_consul()
{
    id=$(doctl compute droplet list --tag-name $consul_vm_tag --format ID --no-header)
    doctl compute droplet rm -f $id || true
}

function destroy_do_runners()
{
    ids=( $(doctl compute droplet list --tag-name $tag --format ID --no-header) )
    if [[ ${#ids[@]} -eq 0 ]]; then
        echo "-- skipping"
        return
    fi

    for id in "${ids[@]}"; do
        doctl compute droplet rm -f $id || true
    done
}

function MAIN()
{
#    shutdown
    destroy_consul
    destroy_do_runners
}

    MAIN
