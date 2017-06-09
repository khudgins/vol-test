#!/usr/bin/env bats

load test_helper

VOL_NAME=redis-vol01
POD_NAME=test-storageos-redis
ALT_NAMESPACE=alternative-pre-provisioned

@test "Create volume using storageos cli" {
  run storageos $cliopts volume create -n default $VOL_NAME
  assert_success
}

@test "Create secret in default namespace" {
  run $kubectl create -f examples/storageos-secret.yaml
  assert_success
}

@test "Confirm volume is created (storageos volume ls) using storageos cli" {
  run storageos $cliopts volume ls
  assert_line --partial $VOL_NAME
}

@test "Create pod using pre-created volume" {
  run $kubectl create -f examples/storageos-pod.yaml
  assert_line --partial "pod \"${POD_NAME}\" created"
}

@test "Wait 10 seconds" {
  run sleep 10
  assert_success
}

@test "Verify pod is running" {
  run bash -c "$kubectl get pod $POD_NAME -o=json | jq -r '.status.phase'"
  assert_line "Running"
}

@test "Delete pod, secret" {
  run $kubectl delete pod $POD_NAME
  assert_line --partial "pod \"${POD_NAME}\" deleted"
  run $kubectl delete -f examples/storageos-secret.yaml
  assert_success
}

@test "create $ALT_NAMESPACE namespace" {
  run $kubectl create namespace ${ALT_NAMESPACE}
  assert_success
}

@test "Create volume in $ALT_NAMESPACE namespace using storageos cli" {
  run storageos $cliopts volume create -n $ALT_NAMESPACE $VOL_NAME
  assert_success
}

@test "Pod is in  different namespace - secret not present, should fail" {
  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-pod.yaml
  assert_line --partial "pod \"${POD_NAME}\" created"
  sleep 10
  run $kubectl describe --namespace=${ALT_NAMESPACE} -f examples/storageos-pod.yaml
  echo $output | grep -e "Unauthorized" -e "secret" -e "FailedMount"
  assert_success
}

@test "Create secret in namespace, Pod should be running" {
  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-secret.yaml
  assert_success
  sleep 10
  run bash -c "$kubectl get pod --namespace=${ALT_NAMESPACE} ${POD_NAME} -o=json | jq -r '.status.phase'"
  assert_line "Running"
}

@test "cleanup k8s" {
  run $kubectl delete namespace ${ALT_NAMESPACE}
  assert_success
}

@test "Delete volume using storageos cli" {
  run storageos $cliopts volume rm -f default/$VOL_NAME
  assert_success
  run storageos $cliopts volume rm -f ${ALT_NAMESPACE}/$VOL_NAME
  assert_success
}
