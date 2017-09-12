#!/bin/bash -ex

#export TF_LOG=1

# TODO: provision new key and add to jenkins slaves

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/..

pushd $PROJECT_DIR

PVTK_PATH=$PROJECT_DIR/keys/temp-key
PUBK_PATH=$PROJECT_DIR/keys/temp-key.pub

SSH_FINGERPRINT=$(ssh-keygen -lf $PUBK_PATH -E md5 | awk '{ print $2 }' | cut -d ':' -f 2-)

terraform destroy -var "tag=stress" \
  -var "do_token=$DO_TOKEN" \
  -var "pub_key_path=$PUBK_PATH" \
  -var "pvt_key_path=$PVTK_PATH" \
  -var "ssh_fingerprint=$SSH_FINGERPRINT" 

rm -rf ./configs/**

rm -f stress-cluster*.tf

popd
