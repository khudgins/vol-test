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
  assert_output --partial "active"
}


@test "Create pod using pvc" {
  run $kubectl create -f examples/storageos-sc-pvcpod.yaml
  assert_line --partial "pod \"test-storageos-redis-sc-pvc\" created"
}

@test "Describe pod" {
  run $kubectl describe pod 'test-storageos-redis-sc-pvc'
  assert_line --partial "/redis-master-data from redis-data (rw)"
}

#@test "Delete pod, pvc and sc" {
#  run $kubectl delete -f examples/storageos-sc-pvcpod.yaml
#  assert_line --partial "pod \"test-storageos-redis-sc-pvc\" deleted"
#  run $kubectl delete -f examples/storageos-sc-pvc.yaml 
#  assert_success
#  run $kubectl delete -f examples/storageos-sc.yaml
#  assert_success
#}

#@test "ensure volume deleted through storageos cli" {
  #run -t storageos $cliopts volume ls | grep '$PVNAME'}
