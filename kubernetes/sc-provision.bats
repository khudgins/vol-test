#!/usr/bin/env bats

load test_helper

SC_NAME=fast
PVC_NAME=fast0001
POD_NAME=test-storageos-redis-sc-pvc
ALT_NAMESPACE=alternative-sc

NS_PVC_NAME=nsfast0001
NS_POD_NAME=test-storageos-redis-ns-sc-pvcpod

@test "create storage class" {
  run $kubectl create -f examples/storageos-sc.yaml
  assert_output "storageclass \"$SC_NAME\" created"
  assert_success
  run $kubectl describe sc
  assert_output --partial "$SC_NAME"
  assert_output --partial "kubernetes.io/storageos"
}

@test "Create secret in $NAMESPACE namespace" {
  run $kubectl create -f examples/storageos-secret.yaml
  assert_success
}

@test "create pvc using storageclass" {
  run $kubectl create -f examples/storageos-sc-pvc.yaml
  assert_output "persistentvolumeclaim \"${PVC_NAME}\" created"
  run $kubectl get pvc
  assert_output --partial "${PVC_NAME}"
}


@test "Create pod using pvc" {
  run $kubectl create -f examples/storageos-sc-pvcpod.yaml
  assert_line --partial "pod \"${POD_NAME}\" created"
}

@test "Describe pod" {
  run $kubectl describe pod "${POD_NAME}"
  assert_line --partial "/redis-master-data from redis-data (rw)"
}

@test "Delete pod, pvc and sc" {
  run $kubectl delete -f examples/storageos-sc-pvcpod.yaml
  assert_line --partial "pod \"${POD_NAME}\" deleted"
  run $kubectl delete -f examples/storageos-sc-pvc.yaml
  assert_success
  run $kubectl delete -f examples/storageos-sc.yaml
  assert_success

  run $kubectl delete -f examples/storageos-secret.yaml
  assert_success
}

@test "create $ALT_NAMESPACE namespace" {
  run $kubectl create namespace ${ALT_NAMESPACE}
  assert_success
}

@test "in different namespace - no secret" {

  run $kubectl create -f examples/storageos-ns-sc-pvc.yaml
  assert_success
  run bash -c "$kubectl describe pvc --namespace=${ALT_NAMESPACE} $NS_PVC_NAME | grep -e ProvisioningFailed -e 'failed to get secret'"
  assert_success
}

@test "add secret, recreate pvc" {
  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-secret.yaml
  assert_success

  run $kubectl delete -f examples/storageos-ns-sc-pvc.yaml
  assert_success

  run $kubectl create -f examples/storageos-ns-sc-pvc.yaml
  assert_success

  sleep 5

  run $kubectl --namespace=${ALT_NAMESPACE} get pvc $NS_PVC_NAME
  assert_line --partial "Bound"

  run $kubectl create -f examples/storageos-ns-sc-pvcpod.yaml
  assert_success

  sleep 10

  run $kubectl --namespace=${ALT_NAMESPACE} get pod $NS_POD_NAME
  assert_line --partial "Running"
}


@test "cleanup k8s" {
  run $kubectl delete namespace ${ALT_NAMESPACE}
  assert_success
}

