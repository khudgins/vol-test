#!/usr/bin/env bats

load ../../test_helper

@test "test cli login" {
  # Should fail as there are no creds set
  run $prefix storageos volume ls
  assert_failure

  run $prefix storageos login localhost --username storageos --password storageos
  assert_success

  # Should work as there are cached creds
  run $prefix storageos volume ls
  assert_success

  run $prefix storageos logout localhost
  assert_success

  # Should fail as there are no creds set
  run $prefix storageos volume ls
  assert_failure
}
