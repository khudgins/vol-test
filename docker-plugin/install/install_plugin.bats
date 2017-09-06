#!/usr/bin/env bats


# is this test up to date?
load ../../test_helper

CID_FILE=$BATS_TEST_DIRNAME/CID

@test "Create cluster allocation" {
 run $prefix storageos $cliopts cluster create
 [[ -n $output ]] && echo $output > $CID_FILE
}

@test "Verify cluster id" {
 export CLUSTER_ID=$(cat $CID_FILE)
 echo $CLUSTER_ID | egrep '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
 assert_success
}

@test "Install plugin on 1st node" {

  run $prefix -t "docker plugin ls | grep $driver"
  if [[ $status -eq 0 ]]; then
    skip
  fi


 #set -x
  run $prefix docker plugin install --alias storageos --grant-all-permissions $driver CLUSTER_ID=$(cat $CID_FILE)
  #set +x
  assert_success
}

@test "Install plugin on 2nd node" {

  run $prefix2 -t "docker plugin ls | grep $driver"
  if [[ $status -eq 0 ]]; then
    skip
  fi

  run $prefix2 docker plugin install --alias storageos --grant-all-permissions $driver CLUSTER_ID=$(cat $CID_FILE)
  assert_success
}

@test "Install plugin on 3rd node" {

  run $prefix3 -t "docker plugin ls | grep $driver"
  if [[ $status -eq 0 ]]; then
    skip
  fi

  run $prefix3 docker plugin install --alias storageos --grant-all-permissions $driver "CLUSTER_ID=$(cat $CID_FILE)"
  assert_success
}
