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

. test.env
pushd docker-plugin
echo "-----------------------------"
echo "installing plugin on 3 nodes"
echo "-----------------------------"
bats -u install_plugin.bats
sleep 30
echo "-----------------------------"
echo "running docker acceptance tests"
echo "-----------------------------"
bats -u singlenode.bats secondnode.bats
popd

for f in acceptance-tests/**/*bats ; do
  echo "-----------------------------"
  echo "$(basename $f) tests in $(dirname $f) suite "
  echo "-----------------------------"
  bats -u $f
done

