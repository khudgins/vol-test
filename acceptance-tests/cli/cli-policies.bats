#!/usr/bin/env bats

load ../../test_helper

@test "create policy" {
  run $prefix storageos $cliopts user create policyTestUser --role user
  echo $output
  assert_success

  run $prefix storageos $cliopts policy create --user policyTestUser --namespace policyTestNamespace
  echo $output
  assert_success
}
