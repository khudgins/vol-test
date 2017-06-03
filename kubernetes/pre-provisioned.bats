#!/usr/bin/env bats

load test_helper

@test "Create volume using storageos cli" {
  run storageos $cliopts volume create -n default redis-vol01
  assert_success
}

@test "Confirm volume is created (storageos volume ls) using storageos cli" {
  run storageos $cliopts volume ls
  assert_line --partial "default/redis-vol01"
}

@test "Create pod using pre-created volume" {
  run $kubectl create -f examples/storageos-pod.yaml
  assert_line --partial "pod \"test-storageos-redis\" created"
}

@test "Wait 10 seconds" {
  run sleep 10
  assert_success
}

@test "Verify pod is running" {
  run bash -c "$kubectl get pod test-storageos-redis -o=json | jq -r '.status.phase'"
  assert_line "Running"
}

@test "Delete pod" {
  run $kubectl delete pod test-storageos-redis
  assert_line --partial "pod \"test-storageos-redis\" deleted"
}

@test "Delete volume using storageos cli" {
  run storageos $cliopts volume rm -f default/redis-vol01
  assert_success
}
