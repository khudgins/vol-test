#!/usr/bin/env bats

load ../../test_helper

@test "create cluster with defaults" {
  run $prefix storageos cluster create
  assert_success
  run $prefix storageos cluster rm $output
  assert_success
}

@test "create cluster with valid size (3)" {
  run $prefix storageos cluster create -s 3
  assert_success
  run $prefix storageos cluster rm $output
  assert_success
}

@test "create cluster with invalid size (4)" {
  run $prefix storageos cluster create -s 4
  assert_failure
  run $prefix storageos cluster rm $output
  assert_success
}

@test "delete cluster" {
  run $prefix storageos cluster create
  assert_success
  run $prefix storageos cluster rm $output
  assert_success
  run $prefix storageos cluster inspect $output
  assert_failure
}

@test "cluster inspect with defaults" {
  run $prefix storageos cluster create
  id=$output
  run $prefix storageos cluster inspect $id
  run $prefix storageos cluster inspect $id --format {{.ID}}
  assert_output $id
  run $prefix storageos cluster inspect $id --format {{.Size}}
  assert_output 3
  run $prefix storageos cluster rm $id
  assert_success
}

@test "cluster health before nodes joined using cluster id" {
  run $prefix storageos cluster create
  run $prefix storageos cluster health $output
  assert_failure
  assert_output "No cluster nodes found"
}

@test "cluster health existing cluster using bad api" {
  STORAGEOS_HOST=999.999.999.999
  run $prefix storageos cluster health
  assert_failure
  assert_output "Get http://999.999.999.999:5705/version: dial tcp: lookup 999.999.999.999: no such host"
}

@test "cluster health existing cluster using api" {
  run $prefix storageos cluster health
  assert_success
}

@test "cluster health existing cluster using api" {
  run $prefix storageos cluster health
  assert_success
}

@test "cluster health default format" {
  run $prefix storageos cluster health
  assert_success
  assert_output --partial "KV"
  assert_output --partial "NATS"
  assert_output --partial "SCHEDULER"
  assert_output --partial "DFS_CLIENT"
  assert_output --partial "DFS_SERVER"
  assert_output --partial "DIRECTOR"
  assert_output --partial "FS_DRIVER"
  assert_output --partial "FS"  
}

@test "cluster health cp format" {
  run $prefix storageos cluster health --format cp
  assert_success
  assert_output --partial "KV"
  assert_output --partial "KV_WRITE"
  assert_output --partial "NATS"
  assert_output --partial "SCHEDULER"
}

@test "cluster health dp format" {
  run $prefix storageos cluster health --format dp
  assert_success
  assert_output --partial "DFS_CLIENT"
  assert_output --partial "DFS_SERVER"
  assert_output --partial "DIRECTOR"
  assert_output --partial "FS_DRIVER"
  assert_output --partial "FS"
}

@test "cluster health quiet" {
  run $prefix storageos cluster health --quiet
  assert_success
}

@test "cluster health quiet cp format" {
  run $prefix storageos cluster health --format cp --quiet
  assert_success
}

@test "cluster health quiet dp format" {
  run $prefix storageos cluster health --format dp --quiet
  assert_success
}

@test "cluster health raw format" {
  run $prefix storageos cluster health --format raw
  assert_success
}

@test "cluster health quiet raw format" {
  run $prefix storageos cluster health --format raw --quiet
  assert_success
}

@test "cluster health custom format" {
  run $prefix storageos cluster health --format {{.Node}}
  assert_success
}
