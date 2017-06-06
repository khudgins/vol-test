#!/usr/bin/env bats

load ../test_helper

export NAMESPACE=test

@test "Create non-replicated volume using driver ($driver)" {
  run $prefix2 docker volume create --driver $driver --opt size=10 stress-sync
  assert_success
}

@test "Confirm volume is created (volume ls) using driver ($driver)" {
  run $prefix2 docker volume ls
  assert_line --partial "stress-sync"
}

@test "Start a container and mount the volume on node 2" {
  run $prefix2 docker run -it -d --name mounter -v stress-sync:/data ubuntu /bin/bash
  assert_success
}

@test "initiate big write in background then trigger replication" {
  $prefix2 docker exec 'mounter dd if=/dev/urandom of=/data/random bs=10M count=100' &
  # wait a little just to ensure operation is in progress..
  sleep 2
# Add replication
  run $prefix2 storageos $cliopts volume update --label-add 'storageos.feature.replicas=2' default/stress-sync
  assert_success
}

@test "Wait for replication, Get a checksum for that binary file" {
  ACTIVE=$(eval "$prefix2" storageos "$cliopts" volume inspect  default/stress-sync | jq 'first.replicas != [] and ( first.replicas + [first.master] | map(.health == "healthy") | all)')
  while ! [[ "$ACTIVE"  == "true" ]]; do
    ACTIVE=$(eval "$prefix2" storageos "$cliopts" volume inspect default/stress-sync | jq 'first.replicas != [] and (first.replicas + [first.master] | map(.health == "healthy") | all)')
    sleep 2
  done

  run $prefix2 'docker exec -i mounter /bin/bash -c "md5sum /data/random > /data/checksum"'
  assert_success
}

# @test "Stop container on node 2" {
#   run $prefix2 docker stop mounter
#   assert_success
# }

# @test "Destroy container on node 2" {
#   run $prefix2 docker rm mounter
#   assert_success
# }

# @test "Stop storageos on node 2" {
#   run $prefix2 docker plugin disable -f $driver
#   assert_success
# }

# @test "Confirm checksum on node 1" {
#   run $prefix docker run -i --rm -v stess-sync:/data ubuntu md5sum --check /data/checksum
#   assert_success
# }

# @test "Re-start storageos on node 2" {
#   run $prefix2 docker plugin enable $driver
#   assert_success
# }

# @test "wait for 60 seconds" {
#   sleep 60
#   assert_success
# }

# @test "Delete volume using storageos cli" {
#   run $prefix storageos $cliopts volume rm default/stress-sync
#   assert_success
# }
