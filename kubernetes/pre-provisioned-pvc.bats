#!/usr/bin/env bats
load test_helper


PV_NAME=pv0001
PVC_NAME=pvc0001
POD_NAME=test-storageos-redis-pvc

ALT_NAMESPACE=alternative-pre-provisioned-pvc

# Basic
@test "Create volume using storageos cli" {
  run storageos $cliopts volume create -n default ${PV_NAME}
  assert_success
}

@test "Confirm volume is created (storageos volume ls) using storageos cli" {
  run storageos $cliopts volume ls
  assert_line --partial "default/${PV_NAME}"
}

@test "Create secret in default namespace" {
  run $kubectl create -f examples/storageos-secret.yaml
  assert_success
}

@test "Create pv" {
  run $kubectl create -f examples/storageos-pv.yaml
  assert_output "persistentvolume \"${PV_NAME}\" created"
}

@test "Verify pv is available" {
  run $kubectl describe pv ${PV_NAME}
  assert_output --partial "Available"
}

@test "Create pvc" {
  run $kubectl create -f examples/storageos-pvc.yaml
  assert_output "persistentvolumeclaim \"${PVC_NAME}\" created"
  sleep 5
}

@test "Verify pvc is bound" {
  run $kubectl describe pvc ${PVC_NAME}
  assert_output --partial "Bound"
}

@test "Verify pv is now bound" {
  run $kubectl describe pv ${PV_NAME}
  assert_output --partial "Bound"
}

@test "Create pod using pvc in default namespace" {
  run $kubectl create -f examples/storageos-pvcpod.yaml
  assert_line --partial "pod \"${POD_NAME}\" created"
}

@test "Describe pod" {
  sleep 20
  run $kubectl describe pod ${POD_NAME}
  assert_line --partial "/redis-master-data from redis-data (rw)"
  assert_line --partial "Ready:		True"
}

@test "Delete pod, pv and pvc" {
  run $kubectl delete pod ${POD_NAME}
  assert_line --partial "pod \"${POD_NAME}\" deleted"
  sleep 30
  run $kubectl delete pvc ${PVC_NAME}
  assert_line --partial "persistentvolumeclaim \"${PVC_NAME}\" deleted"
  run $kubectl delete pv ${PV_NAME}
  assert_line --partial "persistentvolume \"${PV_NAME}\" deleted"
  run $kubectl delete -f examples/storageos-secret.yaml
  assert_success

}

@test "Delete volume using storageos cli" {
  run storageos $cliopts volume rm -f default/${PV_NAME}
  assert_success
}

@test "create $ALT_NAMESPACE namespace" {
  run $kubectl create namespace ${ALT_NAMESPACE}
  assert_success
}

@test "Create volume in $ALT_NAMESPACE namespace using storageos cli" {
  run storageos $cliopts volume create -n $ALT_NAMESPACE $PV_NAME
  assert_success
}


@test "PV is in  different namespace - secret not present, should fail" {
  run $kubectl create -f examples/storageos-ns-pv.yaml
  assert_success

  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-pvc.yaml
  assert_success

  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-pvcpod.yaml
  assert_success
}

@test "Verify pvc is bound" {
  run $kubectl --namespace=${ALT_NAMESPACE} describe pvc ${PVC_NAME}
  assert_output --partial "Bound"
}

@test "Verify pv is now bound" {
  run $kubectl --namespace=${ALT_NAMESPACE} describe pv ${PV_NAME}
  assert_output --partial "Bound"
}

@test "verify pod cannot mount" {
  sleep 10
  run $kubectl describe --namespace=${ALT_NAMESPACE} pod $POD_NAME
  echo $output | grep -e "secret" -e "FailedMount"
  assert_success
}

@test "Create secret in namespace, Pod should be running" {
  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-secret.yaml
  assert_success

  run $kubectl --namespace=${ALT_NAMESPACE} delete pod $POD_NAME
  assert_success

  sleep 20
  run $kubectl create --namespace=${ALT_NAMESPACE} -f examples/storageos-pvcpod.yaml
  assert_success

  sleep 20

  run bash -c "$kubectl get pod --namespace=${ALT_NAMESPACE} ${POD_NAME} -o=json | jq -r '.status.phase'"
  assert_line "Running"
}

@test "cleanup k8s" {
  run $kubectl delete namespace ${ALT_NAMESPACE}
  assert_success

  run $kubectl delete -f examples/storageos-ns-pv.yaml
  assert_success

}

@test "Delete volume using storageos cli" {
  run storageos $cliopts volume rm -f ${ALT_NAMESPACE}/${PV_NAME}
  assert_success
}
