#!/bin/bash -x

# this script will be continually executed from the runner
# it will be running on every node


voluid=$(uuidgen | cut -c1-5)

CREDS="-u storageos -p storageos"

# waiting for controller to be healthy..
sleep 30
storageos $CREDS volume create $voluid

sudo storageos $CREDS volume mount default/$voluid /data

sudo ./kernel-compile.sh

sleep 5

sudo storageos $CREDS volume unmount default/$voluid

storageos -u storageos -p storageos volume rm default/$voluid
