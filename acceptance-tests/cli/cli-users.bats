#!/usr/bin/env bats

load ../../test_helper

@test "create user" {
# TODO: interactive password input using pexpect (already have python dep)
#PYTHON_SCRIPT=$(cat <<EOD
#'import pexpect;
#child = pexpect.spawn("storageos user create awesomeUser --role user --groups foo,bar --password");
#child.expect("Password: ");
#child.sendline("password");
#child.expect(pexpect.EOF)'
#EOD
#)

  run $prefix storageos $cliopts user create awesomeUser --role user --groups foo,bar
  echo $output
  assert_success

  run $prefix storageos $cliopts user inspect awesomeUser
  assert_success

  echo $output | jq '.[0].username == "awesomeUser"'
  echo $output | jq '.[0].groups == "foo,bar"'
  echo $output | jq '.[0].role != "admin"'
}

@test "update user" {
  run $prefix storageos $cliopts user update awesomeUser --role admin --remove-groups foo,bar --add-groups baz,bang
  assert_success

  run $prefix storageos $cliopts user inspect awesomeUser
  assert_success

  echo $output | jq '.[0].groups == "baz,bang"'
  echo $output | jq '.[0].role != "user"'
}

@test "delete user" {
  run $prefix storageos $cliopts user rm awesomeUser
  assert_success

  run $prefix storageos $cliopts user inspect awesomeUser
  assert_failure
}

@test "create admin" {
# TODO: interactive password input using pexpect (already have python dep)
#PYTHON_SCRIPT=$(cat <<EOD
#'import pexpect;
#child = pexpect.spawn("storageos user create awesomeUser --role user --groups foo,bar --password");
#child.expect("Password: ");
#child.sendline("password");
#child.expect(pexpect.EOF)'
#EOD
#)

  run $prefix storageos $cliopts user create awesomeAdmin --role admin --groups foo,bar
  echo $output
  assert_success

  run $prefix storageos $cliopts user inspect awesomeAdmin
  assert_success

  echo $output | jq '.[0].username == "awesomeAdmin"'
  echo $output | jq '.[0].groups == "foo,bar"'
  echo $output | jq '.[0].role != "user"'
}

@test "update admin" {
  run $prefix storageos $cliopts user update awesomeAdmin --role user --remove-groups foo,bar --add-groups baz,bang
  assert_success

  run $prefix storageos $cliopts user inspect awesomeAdmin
  assert_success

  echo $output | jq '.[0].groups == "baz,bang"'
  echo $output | jq '.[0].role != "admin"'
}

@test "delete admin" {
  run $prefix storageos $cliopts user rm awesomeAdmin
  assert_success

  run $prefix storageos $cliopts user inspect awesomeAdmin
  assert_failure
}
