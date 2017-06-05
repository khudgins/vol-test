#!/usr/bin/env bats
load ../test_helper

# Basic
@test "Create volume using storageos cli" {
  run storageos $cliopts volume create -n default pv0001-bad
  assert_success
}

@test "Confirm volume is created (storageos volume ls) using storageos cli" {
  run storageos $cliopts volume ls
  assert_line --partial "default/pv0001-bad"
}


@test "Create pv" {
  run $kubectl create -f "$BATS_TEST_DIRNAME/bad-examples/storageos-pv.yaml"
  assert_output 'persistentvolume "pv0001-bad" created'
}

@test "Ensure pv is available" {
  run $kubectl describe pv pv0001-bad
  echo $output | grep "Available"
  assert_success
}

@test "Create pvc" {
  run $kubectl create -f "$BATS_TEST_DIRNAME/bad-examples/storageos-pvc.yaml"
  assert_output 'persistentvolumeclaim "pvc0001-bad" created'
  sleep 5
}

@test "Verify pvc is not bound" {
  run $kubectl describe pvc pvc0001-bad
  assert_output --partial "Bound"
}

@test "Verify pv is now bound" {
  run $kubectl describe pv pv0001
  assert_output --partial "Bound"
}

@test "Create pod using pvc" {
  run $kubectl create -f "$BATS_TEST_DIRNAME/bad-examples/storageos-pvcpod.yaml"
  assert_line --partial "pod \"test-storageos-redis-pvc-bad\" created"
}

@test "Verify pod was not autorized to mount" {
  run bash -c "$kubectl describe pod test-storageos-redis-pvc-bad | grep -e Unauthorized -e FailedMount"
  assert_success
}

@test "Delete pod, pv and pvc" {
  run $kubectl delete pod test-storageos-redis-pvc-bad
  assert_line --partial "pod \"test-storageos-redis-pvc-bad\" deleted"
  run $kubectl delete pvc pvc0001-bad
  assert_line --partial "persistentvolumeclaim \"pvc0001-bad\" deleted"
  run $kubectl delete pv pv0001-bad
  assert_line --partial "persistentvolume \"pv0001-bad\" deleted"
}

@test "Delete volume using storageos cli" {
  run storageos $cliopts volume rm -f default/pv0001-bad
  assert_success
}
