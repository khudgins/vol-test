#!/bin/bash -ex 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. envfile.sh

  # TODO: provision new key and add to jenkins slaves

if [[ -z $DEPTH ]] || [[ -z "$STORAGEOS_VERSION" ]]; then
  (>2& echo "Please specify the Job you want to run and the container version") 
  exit 1
fi

function main() {
for IaaS in $IAAS; do
    IAASDIR="$DIR/cloud-provisioners/${IaaS}/"
    
    # it is wasteful to run a job if identical depth and identical storageos version 
    JOBUID="${DEPTH}-$(echo $STORAGEOS_VERSION | tr '.' '_')"

    # we take the existence of this unique job file to mean a cluster for this job is running
    # this is what the limitations of bash lead to..
    if [[ -f $IAASDIR/configs/$JOBUID ]]; then
      (>2& echo "Job file already exists, Provisioner failed for suites on $IaaS, continuing..")
      continue 
    else
      file=$(tempfile)

      if [[ $CONTAINER == "true" ]]; then
        cat $IAASDIR/jobs/container/$DEPTH > $file
      else
        cat $IAASDIR/jobs/host/$DEPTH > $file
      fi

      mkdir -p $IAASDIR/configs
      cp -T $file $IAASDIR/configs/$JOBUID
      env JOBUID=$JOBUID STORAGEOS_VERSION=$STORAGEOS_VERSION $IAASDIR/scripts/new-cluster.sh 
    fi

done 
}

main
