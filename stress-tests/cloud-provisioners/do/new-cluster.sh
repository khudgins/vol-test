#!/bin/bash -ex


# TODO: provision new key and add to jenkins slaves

if [[ -z $Suite ]] || [[ -z "$STORAGEOS_CONTAINER_VERSION" ]]; then
  (>2& echo "Please specify the Job you want to run and the container version") 
fi

JOBUID=$Suite-$(echo $STORAGEOS_CONTAINER_VERSION | tr '.' '_')

set +x
find . -type f -name $JOBUID
if [[ $? -eq 0 ]]; then
  (>2& echo "This job already exists, cancel through cancel job to restart") 
  exit 1
fi  
set -x

VERSION=$STORAGEOS_VERSION JOBUID=$JOBUID lib/bash-templater/templater.sh cluster.template > $JOBUID.tf

terraform plan -var "tag=stress"  \
  -var "do_token=4ebbb814ce4d4edb19f4a8c410cdf2944fd74b110f10e5650030bc3802e9a0cb" \
  -var "pub_key=/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/temp-key.pub" \
-var "pvt_key_path=/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/temp-key" \
-var "ssh_fingerprint=b1:cd:87:e6:e9:79:4a:eb:05:a0:83:65:18:18:6e:a5"  -out stress-cluster.plan
