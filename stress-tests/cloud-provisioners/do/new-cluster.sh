#!/bin/bash -ex

export TF_LOG=1

# TODO: provision new key and add to jenkins slaves
terraform refresh -var "region=nyc1" -var "tag=stress"  -var "cluster_id=04ea9a1e-b0cb-442d-8db2-90717f8ea199" -var "cluster_size=3"  -var "do_token=4ebbb814ce4d4edb19f4a8c410cdf2944fd74b110f10e5650030bc3802e9a0cb" \
  -var "pub_key=/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/temp-key.pub" \
-var "pvt_key=/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/temp-key" \
-var "ssh_fingerprint=b1:cd:87:e6:e9:79:4a:eb:05:a0:83:65:18:18:6e:a5" \
-var "ubuntu-version=ubuntu-16-04-x64"

