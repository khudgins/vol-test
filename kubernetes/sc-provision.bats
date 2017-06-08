#!/usr/bin/env bats

load test_helper

@test "create storage class" {
  run $kubectl create -f examples/storageos-sc.yaml
  assert_output 'storageclass "fast" created'
  assert_success
  run $kubectl describe sc
  assert_output --partial "fast"
  assert_output --partial "kubernetes.io/storageos"
}

@test "create pvc using storageclass" {
  run $kubectl create -f examples/storageos-sc-pvc.yaml
  assert_output 'persistentvolumeclaim "fast0001" created'
  run $kubectl get pvc
  assert_output --partial "fast0001"
}


@test "Create pod using pvc" {
  run $kubectl create -f examples/storageos-sc-pvcpod.yaml
  assert_line --partial "pod \"test-storageos-redis-sc-pvc\" created"
}

@test "Describe pod" {
  run $kubectl describe pod 'test-storageos-redis-sc-pvc'
  assert_line --partial "/redis-master-data from redis-data (rw)"
}

@test "Delete pod, pvc and sc" {
 run $kubectl delete -f examples/storageos-sc-pvcpod.yaml
 assert_line --partial "pod \"test-storageos-redis-sc-pvc\" deleted"
 run $kubectl delete -f examples/storageos-sc-pvc.yaml
 assert_success
 run $kubectl delete -f examples/storageos-sc.yaml
 assert_success
}

@test "in different namespace - no secret" {
  run $kubectl create -f examples/storageos-ns-sc.yaml
  assert_success

  run $kubectl create -f examples/storageos-ns-sc-pvc.yaml
  assert_success
  run bash -c "$kubectl describe pod test-storageos-redis-bad | grep -e Unauthorized -e FailedMount"
  assert_success
}

@test "in different namespace, secret added" {
  run $kubectl create namespace test
  assert_success

  $run $kubectl create -f examples/storageos-ns-sc-pvcpod.yaml
  assert_success
}

@test "cleanup" {
  $run $kubectl delete -f examples/storageos-ns-sc-pvcpod.yaml
  assert_success

  run $kubectl delete -f examples/storageos-ns-sc-pvc.yaml
  assert_success

  run $kubectl delete -f examples/storageos-ns-secret.yaml
  assert_success
}

@test "ensure volume deleted through storageos cli" {
  run storageos $cliopts volume ls | grep 'test-storageos-redis-sc-pvc'
  refute
}
