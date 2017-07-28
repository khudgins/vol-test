#!/usr/bin/env bats


# is this test up to date?
load ../../test_helper

CID_FILE=$BATS_TEST_DIRNAME/CID

@test "create cluster" {
 run $prefix storageos $cliopts cluster create
 export CLUSTER_ID=$(echo $output | cut -d ':' -f 2 | xargs)
 [[ -n $CLUSTER_ID ]] && echo $CLUSTER_ID > $CID_FILE
}

@test "Install plugin for driver ($driver) on 1st node with $CLUSTER_ID" {

  run $prefix -t "docker plugin ls | grep $driver"
  if [[ $status -eq 0 ]]; then
    skip
  fi


 set -x
  run $prefix docker plugin install --grant-all-permissions $driver CLUSTER_ID=$(cat $CID_FILE)
  set +x
  assert_success
}

@test "Install plugin for driver ($driver) on 2nd node" {

  run $prefix2 -t "docker plugin ls | grep $driver"
  if [[ $status -eq 0 ]]; then
    skip
  fi

  run $prefix2 docker plugin install --grant-all-permissions $driver CLUSTER_ID=$(cat $CID_FILE)
  assert_success
}

@test "Install plugin for driver ($driver) on 3rd node" {

  run $prefix3 -t "docker plugin ls | grep $driver"
  if [[ $status -eq 0 ]]; then
    skip
  fi

  run $prefix3 docker plugin install --grant-all-permissions $driver "CLUSTER_ID=$(cat $CID_FILE)"
  assert_success
}
