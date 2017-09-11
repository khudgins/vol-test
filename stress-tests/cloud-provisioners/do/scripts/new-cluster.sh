#!/bin/bash -ex

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/..

if [[ -z $JOBUID ]] || [[ -z $STORAGEOS_VERSION ]]; then
  (>&2 echo "incorrect usage of this script, please trigger with ./stress-test-trigger from Top level directory")
  exit 1
fi
# build supervisor binary

# assume that the binary is built and available on GOBIN (FOR NOW)
pushd $PROJECT_DIR

env BINARY_PATH=$PROJECT_DIR/bin/runner VERSION=$STORAGEOS_VERSION JOBUID=$JOBUID "$PROJECT_DIR/lib/bash-templater/templater.sh" "$PROJECT_DIR/templates/cluster.template" > $PROJECT_DIR/$JOBUID.tf
env JOBUID=$JOBUID "$PROJECT_DIR/lib/bash-templater/templater.sh" "$PROJECT_DIR/templates/systemd-service.template" > $PROJECT_DIR/configs/$JOBUID.service

terraform get
terraform init
terraform plan -var "tag=stress"  \
  -var "do_token=4ebbb814ce4d4edb19f4a8c410cdf2944fd74b110f10e5650030bc3802e9a0cb" \
  -var "pub_key=/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/keys/temp-key.pub" \
-var "pvt_key_path=/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/keys/temp-key" \
-var "ssh_fingerprint=b1:cd:87:e6:e9:79:4a:eb:05:a0:83:65:18:18:6e:a5"  -out stress-cluster.plan

popd
