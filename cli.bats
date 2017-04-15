#!/usr/bin/env bats

load test_helper

# Basic
@test "Create volume using storageos cli" {
  run $prefix storageos $cliopts volume create -n default clivol
  assert_success
}

@test "Confirm volume is created (storageos volume ls) using storageos cli" {
  run $prefix storageos $cliopts volume ls
  assert_line --partial "default/clivol"
}

@test "Confirm volume is created (docker volume ls) using driver ($driver)" {
  run $prefix docker volume ls
  assert_line --partial "clivol"
}

@test "Confirm volume inspect works using storageos cli" {
  run $prefix storageos $cliopts volume inspect default/clivol
  assert_line --partial "\"name\": \"clivol"
  assert_line --partial "\"status\": \"active"
}

@test "Confirm docker volume inspect works using driver ($driver)" {
  run $prefix docker volume inspect clivol
  assert_line --partial "\"Driver\": \"$driver"
}

@test "Start a container and mount the volume" {
  run $prefix docker run -it -d --name mounter -v clivol:/data ubuntu /bin/bash
  assert_success
}

@test "Write a textfile to the volume" {
  run $prefix -t 'docker exec -it mounter /bin/bash -c "echo \"testdata\" > /data/foo.txt"'
  assert_success
}

@test "Confirm textfile contents on the volume" {
  run $prefix -t docker exec -it mounter cat /data/foo.txt
  assert_line --partial "testdata"
}

@test "Stop container" {
  run $prefix docker stop mounter
  assert_success
}

@test "Destroy container" {
  run $prefix docker rm mounter
  assert_success
}

@test "Remove volume using storageos cli" {
  run $prefix storageos $cliopts volume rm default/clivol
  assert_success
}

@test "Confirm volume is removed using storageos cli" {
  run $prefix storageos $cliopts volume ls
  refute_output --partial 'default/clivol'
}

# Create options
@test "Create volume using storageos cli with options" {
  run $prefix storageos $cliopts volume create -n default --size 1 --label env=test --label org=dev --description \"test vol\" clivol
  assert_success
}

@test "Confirm volume inspect works using storageos cli (create with options)" {
  run $prefix storageos $cliopts volume inspect default/clivol
  assert_line --partial "\"name\": \"clivol\""
  assert_line --partial "\"description\": \"test vol"\"
  assert_line --partial "\"env\": \"test"\"
  assert_line --partial "\"org\": \"dev"\"
  assert_line --partial "\"status\": \"active"\"
  assert_line --partial "\"size\": 1"
}

@test "Remove volume with options using storageos cli" {
  run $prefix storageos $cliopts volume rm default/clivol
  assert_success
}

# Update
@test "Create basic volume using storageos cli" {
  run $prefix storageos $cliopts volume create -n default clivol
  assert_success
}

@test "Update basic volume using storageos cli" {
  run $prefix storageos $cliopts volume update --size 10 --label-add env=test --label-add org=dev --description \"test vol\" default/clivol
  assert_success
}

@test "Confirm volume inspect sees updated values using storageos cli" {
  run $prefix storageos $cliopts volume inspect default/clivol
  assert_line --partial "\"name\": \"clivol\""
  assert_line --partial "\"description\": \"test vol"\"
  assert_line --partial "\"env\": \"test"\"
  assert_line --partial "\"org\": \"dev"\"
  assert_line --partial "\"status\": \"active"\"
  assert_line --partial "\"size\": 1"
}

@test "Remove updated volume using storageos cli" {
  run $prefix storageos $cliopts volume rm default/clivol
  assert_success
}
