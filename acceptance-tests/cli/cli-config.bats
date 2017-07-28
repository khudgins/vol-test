#!/usr/bin/env bats

load ../../test_helper

@test "auth - incorrect user not allowed" {
  run $prefix storageos -u wrong-user volume ls
  refute [[ $status -eq 0 ]]
}

@test "auth - incorrect pass not allowed" {
  run $prefix storageos -p wrong-pass volume ls
  refute [[ $status -eq 0 ]]
}


