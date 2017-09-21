#!/usr/bin/env bats

load ../../test_helper

export POOL1=pool1
export POOL1_3=pool13
export DESCRIPTION="pool test suite"
export NODE1=$($prefix 'echo $HOSTNAME')
export NODE2=$($prefix2 'echo $HOSTNAME')
export NODE3=$($prefix3 'echo $HOSTNAME')
export NAMESPACE="test"

pool_prefix="$prefix storageos $cliopts pool"

@test "create pool w description for node 1, bogus driver, controller (no check)" {
  run $pool_prefix create -d \'$DESCRIPTION\' --drivers quantumdriver --controllers $NODE1 --controllers "bogus" $POOL1
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

@test "can make pool for node 1 and 3" {
  run $pool_prefix create -d \'$DESCRIPTION\' --drivers filesystem --controllers "$NODE1" --controllers "$NODE3" $POOL1_3
  assert_success
}

@test "inspect pools" {
  # description is not used..
  run $pool_prefix inspect $POOL1
  echo $output | jq "first.name == \"$POOL1\""
  echo $output | jq 'first.driver == "quantumdriver"'
  echo $output | jq 'first.controllers | length == 2'
}

@test "create 2 replica volume in pool1_3, it should have reject disk creation" {
  run $prefix3 storageos $cliopts volume create -n $NAMESPACE -p $POOL1_3 --label 'storageos.feature.replicas=2' "2replicavolume"
  assert_failure
}

@test "list pool" {
  run $pool_prefix ls
  assert_output --partial $POOL1
  assert_output --partial $POOL1_3
  assert_output --partial $DESCRIPTION
}

@test "delete pools" {
  $prefix storageos $cliopts volume rm $NAMESPACE/2replicavolume
  $prefix storageos $cliopts namespace rm test

  run $pool_prefix rm $POOL1
  assert_success
  run $pool_prefix rm $POOL1_3
  run "$pool_prefix ls | grep -e $POOL1 -e $POOL1_3"
  assert_failure
}
