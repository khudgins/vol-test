#!/bin/bash 

# list of envs expected for this script, sourceable
IAAS="do" # currently do and kubeadm
PROFILE="bench-all" # low high or medium for stress  bench-all or bench-small-read for bench
CONTAINER="false" # true or false
STORAGEOS_VERSION="0.8.1" # valid docker hub container eg. storageos/node:0.8.0

# PVTK_PATH=~/.ssh/id_rsa
# PUBK_PATH=~/.ssh/id_rsa.pub
