#!/usr/bin/env bats

load ../../test_helper

export POOL=test-pool
export DESCRIPTION="pool test suite"

pool_prefix="$prefix storageos $cliopts pool"


@test "create pool w description for node 1" {
  run $pool_prefix create -d \'$DESCRIPTION\' -drivers filesystem  $POOL
  assert_success
}

@test "create pool - already exists" {
  run $pool_prefix create $POOL
  assert_failure
}

@test "create pool - no name" {
  run $pool_prefix create
  assert_failure
}

@test "can create disk in pool" {
  run $prefix storageos $cliopts volume create -n $POOL test
  assert_success
}

@test "cannot create same disk in same pool" {
  run $prefix storageos $cliopts volume create -n $POOL test
  assert_failure
}

@test "can create/delete disk in other pool" {
  run $prefix storageos $cliopts volume create -n "other" test
  assert_success
  run $prefix storageos $cliopts volume rm other/test
  assert_success
}

@test "inspect pool" {
  # description is not used..
  run $pool_prefix inspect $pool
  echo $output | jq 'first.name == "test-pool"'
  echo $output | jq 'first.description == "description for pool suite"'
}

@test "list pool" {
  run $pool_prefix ls
  assert_output --partial $POOL
  assert_output --partial $DESCRIPTION
}

@test "update description" {
  run $pool_prefix update $POOL --description \'new description\'
  assert_success
  run $pool_prefix inspect $POOL
  echo $output | jq 'first.description == "new description"'
}

@test "update display name" {
  run $pool_prefix update $POOL --display-name "short"
  assert_success
  run $pool_prefix inspect $POOL
  echo $output | jq 'first.displayName == "short"'
}

@test "delete pool" {
  run $pool_prefix rm $POOL
  assert_success
  run '$pool_prefix ls | grep $pool'
  assert_failure
}
