#!/bin/bash -ex 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Only source env if vars aren't set (by Jenkins) so it can be run manually
if [[ -z $IAAS ]]; then
  . envfile.sh
fi

  # TODO: provision new key and add to jenkins slaves

if [[ -z $PROFILE ]] || [[ -z "$STORAGEOS_VERSION" ]]; then
  (>2& echo "Please specify the Job you want to run and the container version") 
  exit 1
fi

if ! which terraform; then
  (>2& echo "Terraform must be installed and in your path") 
  exit 1
fi

function main() {
for IaaS in $IAAS; do
    IAASDIR="$DIR/cloud-provisioners/${IaaS}/"
    
    # it is wasteful to run a job if identical depth and identical storageos version 
    JOBUID="${PROFILE}-$(echo $STORAGEOS_VERSION | tr '.' '_')-$BUILD_TAG"

      file=$(mktemp)

      if [[ $CONTAINER == "true" ]]; then
        cp $IAASDIR/jobs/benchmark/container/$PROFILE $file
      else
        cp $IAASDIR/jobs/benchmark/host/$PROFILE $file
      fi

      mkdir -p $IAASDIR/configs
      cp -T $file $IAASDIR/configs/$JOBUID
      env DO_TOKEN=$DO_TOKEN PVTK_PATH=$PVTK_PATH PUBK_PATH=$PUBK_PATH JOBUID=$JOBUID STORAGEOS_VERSION=$STORAGEOS_VERSION $IAASDIR/scripts/new-perf-cluster.sh 

done 
}

main
