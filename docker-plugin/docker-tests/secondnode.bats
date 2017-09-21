#!/usr/bin/env bats

load "../../test_helper"

@test "Test: Install plugin for driver (storageos) on node 2" {
  #skip "This test works, faster for rev without it"
  run $prefix2 -t "docker plugin ls | grep storageos"
  if [[ $status -eq 0 ]]; then
    skip
  fi

  run $prefix2 docker plugin disable storageos -f
  run $prefix2 docker plugin rm storageos
  run $prefix2 docker plugin install --grant-all-permissions --alias storageos $driver $pluginopts
  sleep 60
  assert_success
}

@test "Test: Confirm volume is visible on second node (volume ls) using driver (storageos)" {
  run $prefix2 docker volume ls
  assert_line --partial "testvol"
}

@test "Start a container and mount the volume on node 2" {
  run $prefix2 docker run -i -d --name mounter -v testvol:/data ubuntu /bin/bash
  assert_success
}

@test "Confirm textfile contents on the volume from node 2" {
  run $prefix2 docker exec -i mounter cat /data/foo.txt
  assert_line --partial "testdata"
}

@test "Confirm checksum for binary file on node 2" {
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

@test "Remove volume" {
  run $prefix2 docker volume rm testvol
  assert_success
}

@test "Confirm volume is removed from docker ls" {
  sleep 10
  run $prefix2 docker volume ls
  refute_output --partial 'testvol'
}
