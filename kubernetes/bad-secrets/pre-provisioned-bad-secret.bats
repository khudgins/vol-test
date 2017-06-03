#!/usr/bin/env bats

load ../test_helper

@test "Create volume using storageos cli" {
  run storageos $cliopts volume create -n default redis-vol01-bad
  assert_success
}

@test "Confirm volume is created (storageos volume ls) using storageos cli" {
  run storageos $cliopts volume ls
  assert_line --partial "default/redis-vol01-bad"
}

@test "Create pod using pre-created volume" {
  run $kubectl create -f bad-examples/bad-secrets/storageos-pod.yaml
  assert_line --partial "pod \"test-storageos-redis-bad\" created"
}

@test "Wait 10 seconds" {
  run sleep 10
  assert_success
}

@test "Verify pod is not running" {
  run bash -c "$kubectl get pod test-storageos-redis-bad -o=json | jq -r '.status.phase'"
  echo $output | grep 'running'
  ![[ $? -eq 0 ]]
}

@test "Delete pod" {
  run $kubectl delete pod test-storageos-redis
  assert_line --partial "pod \"test-storageos-redis-bad\" deleted"
}

@test "Delete volume using storageos cli" {
  run storageos $cliopts volume rm -f default/redis-vol01-bad
  assert_success
}
