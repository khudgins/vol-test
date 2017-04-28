#!/usr/bin/env bats


# is this test up to date?
load ../test_helper

@test "Install plugin for driver ($driver) on 1st node" {
  run $prefix docker plugin install --grant-all-permissions $driver $pluginopts
  assert_success
}

@test "Install plugin for driver ($driver) on 2nd node" {
  run $prefix2 docker plugin install --grant-all-permissions $driver $pluginopts
  assert_success
}

@test "Install plugin for driver ($driver) on 3rd node" {
  run $prefix3 docker plugin install --grant-all-permissions $driver $pluginopts
  assert_success
}
