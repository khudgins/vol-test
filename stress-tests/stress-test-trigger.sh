#!/bin/bash -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for IaaS in $IAAS; do

  for Suite in $SUITES; do

    SUITE=$Suite $DIR/cloud-provisioners/${IaaS}/new-machine.sh
    if [[ $? -ne 0 ]]; then
      echo "Provisioner failed for suite $Suite, continuing.."
      continue 
    fi
  done

done 
