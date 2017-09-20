#!/usr/bin/env bats

load ../../test_helper

@test "Create replicated volume" {
  run $prefix2 docker volume create --driver storageos $createopts --opt storageos.feature.replicas=1 repl-vol
  assert_success
}

@test "Confirm replicated volume is created (volume ls)" {
  run $prefix2 docker volume ls
  assert_line --partial "repl-vol"
}

@test "Confirm replicated volume has 1 replica using storageos cli" {
  run $prefix2 storageos $cliopts volume inspect default/repl-vol
  assert_line --partial "\"storageos.feature.replicas\": \"1\"",
}

@test "Start a container and mount the replicated volume on node 2" {
  run $prefix2 docker run -i -d --name mounter -v repl-vol:/data ubuntu /bin/bash
  assert_success
}

@test "Create a binary file" {
  run $prefix2 docker exec -i 'mounter dd if=/dev/urandom of=/data/random bs=10M count=1'
  assert_output --partial "10 M"
}

@test "Get a checksum for that binary file" {
  run $prefix2 'docker exec -i mounter /bin/bash -c "md5sum /data/random > /data/checksum"'
  assert_success
}

@test "Confirm checksum on node 2" {
  run $prefix2 docker exec -i mounter md5sum --check /data/checksum
  assert_success
}

@test "Stop container on node 2" {
  run $prefix2 docker stop mounter
  assert_success
}

@test "Destroy container on node 2" {
  run $prefix2 docker rm mounter
  assert_success
}

@test "Stop storageos on node 2" {
  run $prefix2 docker plugin disable -f storageos
  assert_success
}

@test "Wait 60 seconds" {
  sleep 60
  assert_success
}

@test "Confirm checksum on node 1" {
  run $prefix docker run -i --rm -v repl-vol:/data ubuntu md5sum --check /data/checksum
  assert_success
}

@test "Re-start storageos on node 2" {
  run $prefix2 docker plugin enable storageos
  assert_success
}

@test "Delete volume using storageos cli" {
  run $prefix storageos $cliopts volume rm -f default/repl-vol
  assert_success
}
