#!/usr/bin/env bats

# shellcheck disable=SC2034,SC2153

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

load "$DIR/test/test_helper/bats-support/load.bash"
load "$DIR/test/test_helper/bats-assert/load.bash"

driver="$VOLDRIVER"
prefix="$PREFIX"
prefix2="$PREFIX2"
prefix3="$PREFIX3"
createopts="$CREATEOPTS"
pluginopts="$PLUGINOPTS"
cliopts="$CLIOPTS"
