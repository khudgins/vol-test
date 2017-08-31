#!/bin/bash -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for IaaS in $IAAS; do
  # resources is a JSON object representing machines for that IaaS
  # eg [{"ip":"124.52.42.32","containerver": "storageos/node:0.8.0", "job":"null"}, // if jobs has finished on a node, can reuse
  #    {"ip":"144.26.35.2", "containerver":"storageos/node:0.8.0, "job" : "fio"}] 

  RESOURCES=$($DIR/cloud-provisioners/${IaaS}/fetch-iaas-resources.sh);

  # machines running the desired version of storageos
  RES_W_CONTAINER=$(echo $RESOURCES | jq ".[] | select(.containerver  == $STORAGEOS_CONTAINER)")

  # we repurpose free machines:
  FREE_MACHINE=$( echo $RES_W_CONTAINER | jq '.select(.job == "null")[0]')  

  for Suite in $SUITES; do
    if [[echo $($RES_W_CONTAINER | jq ".job == $Suite") == "true" ]]; then
      echo "this container is already being stress tested with job $Job, cancel this job if you wish to redeploy"
      continue;
    else
      if [[ -z $FREE_MACHINE ]]; then
        $DIR/cloud-provisioners/${IaaS}/reuse-machine.sh $Suite $FREE_MACHINE
      else
        $DIR/cloud-provisioners/${IaaS}/new-machine.sh $Suite
      fi
    fi
  done

done 
