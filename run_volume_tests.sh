#!/bin/bash

# Test wrapper script.
# You can run with environment variables, or
# run this script with uncommented vars and
# appropriate values to your environment.

#VOLDRIVER=yourorg/volume-plugin:tag
#PREFIX=ssh 192.168.42.97
#PREFIX2=ssh 192.168.42.75
#PLUGINOPTS='PLUGIN_API_KEY="keystring goes here" PLUGIN_API_HOST="192.168.42.97"'
#CREATEOPTS='-o profile=database'

if ! [[ -f user_provision.sh ]]; then
  BATS_OPTS='-u'
fi

. ./test.env
pushd docker-plugin
echo "-----------------------------"
echo "installing plugin on 3 nodes"
echo "-----------------------------"
pushd ./install
  bats $BATS_OPTS .
popd
sleep 30
echo "-----------------------------"
echo "running docker acceptance tests"
echo "-----------------------------"
pushd ./docker-tests
# these docker provided tests have to be done in order
  bats $BATS_OPTS singlenode.bats secondnode.bats
popd
popd

for d in acceptance-tests/** ; do
  echo "-----------------------------"
  echo  "$d bats suite running"
  echo "-----------------------------"
  pushd "$d"
   bats $BATS_OPTS .
  popd
done
