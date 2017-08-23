#!/usr/bin/env bats

load ../../test_helper

export NAMESPACE=test-namespace
export DESCRIPTION="descriptionfornamespacesuite"

namespace_prefix="$prefix storageos $cliopts namespace"


@test "create namespace w description" {
  run $namespace_prefix create -d \'$DESCRIPTION\' $NAMESPACE
  assert_success
}

@test "create namespace - already exists" {
  run $namespace_prefix create $NAMESPACE
  assert_failure
}

@test "create namespace - no name" {
  run $namespace_prefix create
  assert_failure
}

@test "create namespace - non-admin" {
  run $prefix storageos $cliopts user create awesomeUser --password foobar123
  assert_success

  run $prefix storageos -u awesomeUser -p foobar123 namespace create
  assert_failure

  run $prefix storageos $cliopts user rm awesomeUser
  assert_success
}

@test "can create disk in namespace" {
  run $prefix storageos $cliopts volume create -n $NAMESPACE test
  assert_success
}

@test "cannot create same disk in same namespace" {
  run $prefix storageos $cliopts volume create -n $NAMESPACE test
  assert_failure
}

@test "can create/delete disk in other namespace" {
  run $prefix storageos $cliopts volume create -n "other" test
  assert_success
  run $prefix storageos $cliopts volume rm other/test
  assert_success
}

@test "inspect namespace" {
  # description is not used..
  run $namespace_prefix inspect $NAMESPACE
  echo $output | jq 'first.name == "test-namespace"'
  echo $output | jq 'first.description == "description for namespace suite"'
}

@test "second node can see namespace" {
  run $prefix2 storageos $cliopts namespace inspect $NAMESPACE
  echo $output | jq 'first.name == "test-namespace"'
  echo $output | jq 'first.description == "description for namespace suite"'
}

@test "list namespace" {
  run $namespace_prefix ls
  assert_output --partial $NAMESPACE
  assert_output --partial $DESCRIPTION
}

@test "update description" {
  run $namespace_prefix update $NAMESPACE --description \'new description\'
  assert_success
  run $namespace_prefix inspect $NAMESPACE
  echo $output | jq 'first.description == "new description"'
}

@test "update display name" {
  run $namespace_prefix update $NAMESPACE --display-name "short"
  assert_success
  run $namespace_prefix inspect $NAMESPACE
  echo $output | jq 'first.displayName == "short"'
}

@test "delete namespace" {
  run $namespace_prefix rm $NAMESPACE
  assert_success
  run $namespace_prefix rm other
  run '$namespace_prefix ls | grep -e $NAMESPACE -e other'
  assert_failure
}

