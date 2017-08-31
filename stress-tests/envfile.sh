#!/bin/bash 

# list of envs expected for this script, sourceable
IAAS= # currently do and kubeadm
DEPTH= # Low High or Medium
SUITES= # fio db-stress kernel-compile
CONTAINER= # true or false
RESTART= # true or false
STORAGEOS_CONTAINER= # valid docker hub container eg. storageos/node:0.8.0

