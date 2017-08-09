#!/bin/bash

set -e

. test.env || true

tag="${DO_TAG}"

if [[ -f user_provision.sh ]] && [[  -z "$JENKINS_JOB" ]]; then
    echo "Loading user settings overrides from user_provision.sh"
    . ./user_provision.sh
fi

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
}

function destroy_do_runners()
{
    ids=( $($doctl_auth compute droplet list --tag-name "$tag" --format ID --no-header) )
    if [[ ${#ids[@]} -eq 0 ]]; then
        echo "-- skipping"
        return
    fi

    for id in "${ids[@]}"; do
        echo "deleting $id"
        $doctl_auth compute droplet rm -f "$id" || true
    done
}

function delete_tags()
{
    $doctl_auth compute tag delete -f "$tag"
}

function MAIN()
{
    set -x
    export doctl_auth
    doctl_auth="doctl -t $DO_TOKEN"
    destroy_do_runners
    delete_tags
    set +x
}

    MAIN
