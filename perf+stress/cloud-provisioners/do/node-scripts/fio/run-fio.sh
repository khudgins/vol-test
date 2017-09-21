#!/bin/bash -x


# this script will be continually executed from the runner
# it will be running on every node
NODE_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

USAGE="Usage: $0 testtype blocksize disktype"

if [ "$#" -ne "3" ]; then
  echo "$USAGE"
  exit 1
fi

TEST_TYPE=$1
BSIZE=$2
DOPTIONS=$3

voluid=$(uuidgen | cut -c1-5)

# waiting for controller to be healthy..
sleep 30


case $DOPTIONS in
  1-rep)
    LABELS="--label storageos.feature.replicas=1"
    ;;
  2-rep)
    LABELS="--label storageos.feature.replicas=2"
    ;;
  no-cache)
    LABELS="--label storageos.feature.nocache=true"
    ;;
  **)
    LABELS=""
    ;;
esac

if [[ $TEST_TYPE == "basic" ]]; then
  RW="randread"  
else
  RW="randwrite"
fi

CREDS="-u storageos -p storageos"
storageos $CREDS volume create $LABELS $voluid

STORAGEOS_VOLID=$(storageos $CREDS volume inspect default/$voluid | jq --raw-output '.[] | .id')

sudo -E $NODE_SCRIPT_DIR/src/dpload/fio-stress/fio-stress.sh $TEST_TYPE.fio --bs=$BSIZE --filename /var/lib/storageos/volumes/$STORAGEOS_VOLID --rw $RW

storageos $CREDS volume rm default/$voluid

