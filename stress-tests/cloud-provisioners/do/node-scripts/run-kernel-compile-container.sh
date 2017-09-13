#!/bin/bash -ex

# this script will be continually executed from the runner
# it will be running on every node

voluid=$(uuidgen | cut -c1:5)

# waiting for controller to be healthy..
sleep 30
storageos -u storageos -p storageos volume create $voluid

sudo docker run -v $voluid:/data soegarots/kernel-compile:0.0.2

storageos -u storageos -p storageos volume rm default/$voluid
