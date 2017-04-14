#!/usr/bin/env bats

load 'test/test_helper/bats-support/load'
load 'test/test_helper/bats-assert/load'

driver=$VOLDRIVER
prefix=$PREFIX
prefix2=$PREFIX2
prefix3=$PREFIX3
createopts="$CREATEOPTS"
pluginopts="$PLUGINOPTS"
cliopts="$CLIOPTS"
