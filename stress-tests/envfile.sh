#!/bin/bash 

# list of envs expected for this script, sourceable
IAAS="do" # currently do and kubeadm
DEPTH="Low" # Low High or Medium
SUITES="kernel-compile" # fio db-stress kernel-compile
CONTAINER="true" # true or false
STORAGEOS_VERSION="0.8.1" # valid docker hub container eg. storageos/node:0.8.0
#SUPERVISOR_BRANCH= # commit or branch 
