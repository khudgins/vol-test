#!/usr/bin/env bats

load ../test_helper

@test "create storage class" {
  run $kubectl create -f bad-examples/storageos-sc.yaml
  assert_output 'storageclass "fast-bad" created'
  assert_success
  run $kubectl describe sc
  assert_output --partial "fast-bad"
  assert_output --partial "kubernetes.io/storageos"
}

@test "create pvc using storageclass" {
  run $kubectl create -f bad-examples/storageos-sc-pvc.yaml
  assert_output 'persistentvolumeclaim "fast0001-bad" created'
  run $kubectl get pvc
  assert_output --partial "fast0001-bad"
  assert_output --partial "active"
}


@test "Create pod using pvc" {
  run $kubectl create -f bad-examples/storageos-sc-pvcpod.yaml
  assert_line --partial "pod \"test-storageos-redis-sc-pvc-bad\" created"
}

@test "Describe pod" {
  run $kubectl describe pod 'test-storageos-redis-sc-pvc-bad'
  assert_line --partial "/redis-master-data from redis-data (rw)"
}

@test "Delete pod, pvc and sc" {
  run $kubectl delete -f bad-examples/storageos-sc-pvcpod.yaml
  assert_line --partial "pod \"test-storageos-redis-sc-pvc-bad\" deleted"
  run $kubectl delete -f bad-examples/storageos-sc-pvc.yaml
  assert_success
  run $kubectl delete -f bad-examples/storageos-sc.yaml
  assert_success
}

#@test "ensure volume deleted through storageos cli" {
  #run -t storageos $cliopts volume ls | grep '$PVNAME'}
