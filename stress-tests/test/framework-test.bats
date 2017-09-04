# these tests use a fake provisioner called test

@test "when a new job is triggered, it provisions one of them w right specs" {

  # test setup
  TEST_PROVDIR=$BATS_TEST_DIRNAME/../cloud-provisioners/test

  cat > "$TEST_PROVDIR/fetch-iaas-resources.sh" <<SCRIPT
  echo -En '[{"res-name":"test-machine-1","containerver":"storageos/node:0.8.0","job":"null"},{"res-name":"test-machine-2","containerver":"storageos/node:0.8.0","job":"fio"}]'
SCRIPT

  cat > "$TEST_PROVDIR/new-machine.sh" <<SCRIPT
  echo "recording env , args and num invocations"
  echo \$@ >> "$BATS_TMPDIR"/NEW_MACHINE_TEST_ARGS
  echo 'env' >> "$BATS_TMPDIR"/NEW_MACHINE_TEST_ENV
SCRIPT

  chmod u+x "$TEST_PROVDIR/fetch-iaas-resources.sh"
  chmod u+x "$TEST_PROVDIR/new-machine.sh"
  # run

  EXPECTED_ENV='IAAS=test DEPTH=Low SUITES=fio CONTAINER=true STORAGEOS_CONTAINER=storageos/node:0.8.0'
  env "$EXPECTED_ENV" ../stress-test-trigger.sh 
    
  # check right script + env + args called
  ! [[ -f "$BATS_TMPDIR"/NEW_MACHINE_TEST_ARGS ]]

  for ENVIR in "${EXPECTED_ENV}" ; do
  grep "$ENVIR" "$BATS_TMPDIR/NEW_MACHINE_TEST_ENV"
  done

  grep "test-machine-2" "$BATS_TMPDIR/REUSE_MACHINE_TEST_ARGS"
}

@test "when a new machine fails to provision , it gives a helpful error message" {

  # test setup
  TEST_PROVDIR=$BATS_TEST_DIRNAME/../cloud-provisioners/test

  cat > "$TEST_PROVDIR/fetch-iaas-resources.sh" <<SCRIPT
  echo -En [{"res-name":"test-machine-1","containerver":"storageos/node:0.8.0","job":"null"},{"res-name":"test-machine-2","containerver":"storageos/node:0.8.0","job":"fio"}]
SCRIPT

  cat > "$TEST_PROVDIR/new-machine.sh" <<SCRIPT
  echo "recording env , args and num invocations"
  exit 1
SCRIPT

  chmod u+x "$TEST_PROVDIR/fetch-iaas-resources.sh"
  chmod u+x "$TEST_PROVDIR/new-machine.sh"
  # run

  EXPECTED_ENV='IAAS=test DEPTH=Low SUITES=fio CONTAINER=true STORAGEOS_CONTAINER=storageos/node:0.8.0'
  run env "$EXPECTED_ENV" ../stress-test-trigger.sh
  [ "$status" -ne 1 ]
  [ "$output" = "provisioner test: failed to provision new machine for $SUITES" ]
}

