#!/bin/bash -ex

export TF_LOG=1

terraform apply   -var "do_token=${DO_PAT}"   -var "pub_key=$HOME/.ssh/id_rsa.pub"   -var "pvt_key=$HOME/.ssh/id_rsa"  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" -var "ssh_fingerprint=LTrfcC19HVBHpVfyIXSYPvuCJIkAWfFHKzAX9XG+yv0" -var "ubuntu-version=ubuntu-16-04-x64" 

