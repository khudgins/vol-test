#!/bin/bash -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. envfile.sh

for IaaS in $IAAS; do

  for Suite in $SUITES; do

    env SUITE=$Suite STORAGEOS_VERSION=$STORAGEOS_VERSION $DIR/cloud-provisioners/${IaaS}/new-cluster.sh
    if [[ $? -ne 0 ]]; then
      echo "Provisioner failed for suite $Suite, continuing.."
      continue 
    fi
  done

done 
