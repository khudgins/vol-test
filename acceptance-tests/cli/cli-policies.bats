#!/usr/bin/env bats

load ../../test_helper

@test "create policy" {
  run $prefix storageos $cliopts user create policyTestUser --role user --password policiesAreCool
  assert_success

  run $prefix storageos $cliopts namespace create policytestnamespace
  assert_success

  run $prefix storageos $cliopts policy create --user policyTestUser --namespace policytestnamespace
  assert_success
}

@test "policy enforcement" {
  run $prefix storageos $cliopts user create unprivileged --role user --password policiesAreCool
  assert_success

  run $prefix storageos -u unprivileged -p policiesAreCool volume create myVol --namespace policytestnamespace
  assert_failure

  run $prefix storageos -u policyTestUser -p policiesAreCool volume create myVol --namespace policytestnamespace
  assert_success

}
