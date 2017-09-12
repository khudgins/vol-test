#!/bin/bash -x

# this script will be continually executed from the runner
# it will be running on every node
storageos -u storageos -p storageos volume ls | grep $HOSTNAME
if [[ $? -eq 0 ]]; then
  echo "volume already exists, no need to reprovision"
else
  sleep 30
  storageos -u storageos -p storageos volume create $HOSTNAME
fi


