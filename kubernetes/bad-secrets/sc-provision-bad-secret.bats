#!/usr/bin/env bats

load ../test_helper

@test "create storage class" {
  run $kubectl create -f "$BATS_TEST_DIRNAME/bad-examples/storageos-sc.yaml"
  assert_output 'storageclass "fast-bad" created'
  assert_success
  run $kubectl describe sc
  assert_output --partial "fast-bad"
  assert_output --partial "kubernetes.io/storageos"
}

@test "create pvc failed with unautorised using storageclass" {
  run $kubectl create -f "$BATS_TEST_DIRNAME/bad-examples/storageos-sc-pvc.yaml"
  assert_output 'persistentvolumeclaim "fast0001-bad" created'
  run $kubectl get pvc
  assert_output --partial "fast0001-bad"
  assert_output --partial "Pending"
  run $kubectl describe pvc fast0001-bad
  assert_output --partial "Unauthorized"
  assert_output --partial "ProvisioningFailed"
}

@test "Create pod using pvc" {
  run $kubectl create -f "$BATS_TEST_DIRNAME/bad-examples/storageos-sc-pvcpod.yaml"
  assert_line --partial "pod \"test-storageos-redis-sc-pvc-bad\" created"
}

@test "Delete pod, pvc and sc" {
  run $kubectl delete -f "$BATS_TEST_DIRNAME/bad-examples/storageos-sc-pvcpod.yaml"
  assert_line --partial "pod \"test-storageos-redis-sc-pvc-bad\" deleted"
  run $kubectl delete -f "$BATS_TEST_DIRNAME/bad-examples/storageos-sc-pvc.yaml"
  assert_success
  run $kubectl delete -f "$BATS_TEST_DIRNAME/bad-examples/storageos-sc.yaml"
  assert_success
}

