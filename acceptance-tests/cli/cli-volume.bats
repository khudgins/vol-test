#!/usr/bin/env bats

load ../../test_helper

export VOL_NAME=vol1
export NAMESPACE=test
export FULL_NAME=$NAMESPACE/$VOL_NAME

vol_prefix="$prefix storageos $cliopts volume"

@test "create disk with size, description and fstype" {
  # awaiting bug fix for description: DEV-1238
  run $vol_prefix create  -f reiserfs -d \'1Gb disk for disk create tests\' -s 1 -n $NAMESPACE $VOL_NAME
  assert_success
  assert_output $FULL_NAME
}

@test "create disk - no name" {
  run $vol_prefix create -n $NAMESPACE
  assert_failure
  # current error message is bad.. should be stopped at cli and not return from api
  # message should contain please provide name for disk :
  # assert_output --partial "please provide name for disk"
}

@test "create disk -  no namespace" {
  run $vol_prefix create nonamespace
  assert_failure
  assert_output --partial "no namespace provided"
}

@test "create disk - already exists in namespace" {
  run $vol_prefix create  -n $NAMESPACE -s 1 $VOL_NAME
  assert_failure
  assert_output --partial "Volume with name '$VOL_NAME' already exists"
}

@test "inspect disk " {
  run $vol_prefix inspect $FULL_NAME
  echo $output | jq 'first.namespace == "test"'
  echo $output | jq 'first.fsType == "reiserfs"'
  echo $output | jq "first.name == \"$VOL_NAME\""
  echo $output | jq 'first.size == 1'
  echo $output | jq 'first.master.status == "active"'
}

@test "inspect - no disk" {
  run $vol_prefix inspect
  assert_failure
}

@test "update - size to 2gb" {
  run $vol_prefix update -s 2 $FULL_NAME
  run $vol_prefix inspect $FULL_NAME
  echo $output | jq 'first.size == 2'
}

@test "update - size 0" {
  run $vol_prefix update -s 0 $FULL_NAME
  assert_failure
}

@test "update - size negative" {
  run $vol_prefix update -s -1 $FULL_NAME
  assert_failure
}

@test "delete disk" {
  run $vol_prefix rm $FULL_NAME
  assert_success
}

@test "delete disk not present" {
  run $vol_prefix rm "NONEXIST/NONEXIST"
  assert_failure
}

@test "delete disk - no disk" {
  run $vol_prefix rm
  assert_failure
}
