#!/bin/bash -ex

sudo storageos -u storageos -p storageos mount $HOSTNAME /data

./kernel-compile.sh
