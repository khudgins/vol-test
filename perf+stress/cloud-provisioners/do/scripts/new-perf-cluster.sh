#!/bin/bash -ex

export TF_LOGS=TRACE

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/..

PVTK_PATH=${PVTK_PATH:=~/.ssh/id_rsa}
PUBK_PATH=${PUBK_PATH:=~/.ssh/id_rsa.pub}
if [[ -z $JOBUID ]] || [[ -z $STORAGEOS_VERSION ]]; then
  (>&2 echo "incorrect usage of this script, please trigger with ./stress-test-trigger from Top level directory")
  exit 1
fi

# assume that the binary is built and available  in /bin
pushd $PROJECT_DIR

env BINARY_PATH=$PROJECT_DIR/bin/ VERSION=$STORAGEOS_VERSION JOBUID=$JOBUID "$PROJECT_DIR/lib/bash-templater/templater.sh" "$PROJECT_DIR/templates/perf-cluster.template" > $PROJECT_DIR/stress-cluster-$JOBUID.tf
env INFLUX_CONN=$INFLUX_CONN JOBUID=$JOBUID "$PROJECT_DIR/lib/bash-templater/templater.sh" "$PROJECT_DIR/templates/systemd-service.template" > $PROJECT_DIR/configs/$JOBUID.service

terraform get
terraform init

SSH_FINGERPRINT=$(ssh-keygen -lf $PUBK_PATH -E md5 | awk '{ print $2 }' | cut -d ':' -f 2-)

terraform apply -var "tag=perf-$BUILD_TAG" \
  -var "do_token=$DO_TOKEN" \
  -var "pub_key_path=$PUBK_PATH" \
  -var "pvt_key_path=$PVTK_PATH" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT" 

popd
