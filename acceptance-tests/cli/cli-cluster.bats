#!/usr/bin/env bats

load ../../test_helper

@test "create cluster with defaults" {
  run storageos cluster create
  assert_success
  run storageos cluster rm $output
  assert_success
}

@test "create cluster with valid size (3)" {
  run storageos cluster create -s 3
  assert_success
  run storageos cluster rm $output
  assert_success
}

@test "create cluster with invalid size (4)" {
  run storageos cluster create -s 4
  assert_failure
  run storageos cluster rm $output
  assert_success
}

@test "delete cluster" {
  run storageos cluster create
  assert_success
  run storageos cluster rm $output
  assert_success
  run storageos cluster inspect $output
  assert_failure
}

@test "cluster inspect with defaults" {
  run storageos cluster create
  id=$output
  run storageos cluster inspect $id
  run storageos cluster inspect $id --format {{.ID}}
  assert_output $id
  run storageos cluster inspect $id --format {{.Size}}
  assert_output 3
  run storageos cluster rm $id
  assert_success
}

@test "cluster health before nodes joined using cluster id" {
  run storageos cluster create
  run storageos cluster health $output
  assert_failure
  assert_output "No cluster nodes found"
}

@test "cluster health existing cluster using bad api" {
  STORAGEOS_HOST=999.999.999.999
  run storageos cluster health
  assert_failure
  assert_output "Get http://999.999.999.999:5705/version: dial tcp: lookup 999.999.999.999: no such host"
}

@test "cluster health existing cluster using api" {
  run storageos cluster health
  assert_success
}

@test "cluster health existing cluster using api" {
  run storageos cluster health
  assert_success
}

@test "cluster health default format" {
  run storageos cluster health
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
  run storageos cluster health --format cp
  assert_success
  assert_output --partial "KV"
  assert_output --partial "KV_WRITE"
  assert_output --partial "NATS"
  assert_output --partial "SCHEDULER"
}

@test "cluster health dp format" {
  run storageos cluster health --format dp
  assert_success
  assert_output --partial "DFS_CLIENT"
  assert_output --partial "DFS_SERVER"
  assert_output --partial "DIRECTOR"
  assert_output --partial "FS_DRIVER"
  assert_output --partial "FS"
}

@test "cluster health quiet" {
  run storageos cluster health --quiet
  assert_success
}

@test "cluster health quiet cp format" {
  run storageos cluster health --format cp --quiet
  assert_success
}

@test "cluster health quiet dp format" {
  run storageos cluster health --format dp --quiet
  assert_success
}

@test "cluster health raw format" {
  run storageos cluster health --format raw
  assert_success
}

@test "cluster health quiet raw format" {
  run storageos cluster health --format raw --quiet
  assert_success
}

@test "cluster health custom format" {
  run storageos cluster health --format {{.Node}}
  assert_success
}
