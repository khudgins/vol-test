#!/bin/bash -ex

# this script will be continually executed from the runner
# it will be running on every node


voluid=$(uuidgen | cut -c1-5)

CREDS="-u storageos -p storageos"

# waiting for controller to be healthy..
sleep 30
storageos $CREDS volume create $voluid

sudo storageos $CREDS mount default/$voluid /data

./kernel-compile.sh

sudo storageos $CREDS umount /data

storageos -u storageos -p storageos volume rm default/$voluid
