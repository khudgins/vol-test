#!/usr/bin/env bats

load ../../test_helper

export VOL_NAME=vol1
export NAMESPACE=test

@test "create disk with size, description and fstype" {
  # awaiting bug fix for description: DEV-1238
  run $prefix storageos $cliopts volume create  -f reiserfs -d '1Gbdiskfordiskcreatetests' -s 1 -n $NAMESPACE $VOL_NAME
  assert_success
  assert_output $NAMESPACE/$VOL_NAME
}

@test "create disk - no name" {
  run $prefix storageos $cliopts volume create -n $NAMESPACE
  assert_failure
  # current error message is bad.. should be stopped at cli and not return from api
  # message should contain please provide name for disk :
  # assert_output --partial "please provide name for disk"
}

@test "create disk -  no namespace" {
  run $prefix storageos $cliopts volume create nonamespace
  assert_failure
  assert_output --partial "no namespace provided"
}

@test "create disk - already exists in namespace" {
  run $prefix storageos $cliopts volume create  -n $NAMESPACE -s 1 $VOL_NAME
  assert_failure
  assert_output --partial "Volume with name '$VOL_NAME' already exists"
}

@test "inspect disk " {
  run $prefix storageos $cliopts volume inspect  $NAMESPACE/$VOL_NAME
  echo $output | jq 'first.namespace == "test"'
  echo $output | jq 'first.fsType == "reiserfs"'
  # TODO: there should be a way to inject var to jq expression .. just not on friday..
  echo $output | jq 'first.name == "vol1"'
  echo $output | jq 'first.size == 1'
  echo $output | jq 'first.master.status == "active"'
}

@test "inspect - no disk" {
  run $prefix storageos $cliopts volume inspect
  assert_failure
}

@test "update - size to 2gb" {
  run $prefix storageos $cliopts volume update -s 2 $NAMESPACE/$VOL_NAME
  run $prefix storageos $cliopts volume inspect test/test
  echo $output | jq 'first.size == 2'
}

@test "update - size 0" {
  run $prefix storageos $cliopts volume update -s 0 $NAMESPACE/$VOL_NAME
  assert_failure
}

@test "update - size negative" {
  run $prefix storageos $cliopts volume update -s -1 $NAMESPACE/$VOL_NAME
  assert_failure
}

@test "delete disk" {
  run $prefix storageos $cliopts volume rm "$NAMESPACE/$VOL_NAME"
  assert_success
}
