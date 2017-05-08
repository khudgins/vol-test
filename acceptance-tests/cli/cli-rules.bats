#!/usr/bin/env bats

load ../../test_helper

export NAMESPACE=test
export NAMESPACE_WRONG=test2

export REPL_RULE_NAME='replicator'
export FREPL_RULE_NAME="$NAMESPACE/$REPL_RULE_NAME"

export NO_REPL_RULE_NAME='de-replicator'
export FNO_REPL_RULE_NAME="$NAMESPACE/$NO_REPL_RULE_NAME"

export VOL_BASE='rule-test-volume'

export VOL1=${VOL_BASE}-1
export VOL2=${VOL_BASE}-2
export VOL3=${VOL_BASE}-3
export VOL4=${VOL_BASE}-4

rule_prefix="$prefix storageos $cliopts rule"
vol_prefix="$prefix storageos $cliopts volume"

@test "create replicator rule for repl=true" {
	run $rule_prefix create -d \'a simple rule that replicates\' \
		--namespace $NAMESPACE --selector 'repl=true' --action add \
		--label storageos.feature.replicas=1 $REPL_RULE_NAME
	assert_success
}

@test "add norepl rule" {
	run $rule_prefix create -d \'a rule for no replication in test namespace\' \
		--namespace $NAMESPACE --selector 'no-repl=true' --action remove \
		--label storageos.feature.replicas=1 $NO_REPL_RULE_NAME
	assert_success
}

@test "attach norepl namespace label to $NAMESPACE" {
	run $prefix storageos $cliopts namespace update --label-add "no-repl=true" $NAMESPACE
	assert_success
}

@test "create volume in namespace $NAMESPACE, rule is applied" {
	run $vol_prefix create -n $NAMESPACE $VOL1
	assert_success
	run $vol_prefix inspect $NAMESPACE/$VOL1
	echo $output | jq "first.labels | contains({\"no-repl\":\"true\"})"
	echo $output | jq 'first.labels | contains({"storageos.feature.replicas":"1"}) | not'
}

@test "create test volume in $NAMESPACE namespace with repl=true label" {
	run $vol_prefix create -n $NAMESPACE $VOL2 --label 'repl=true'
	assert_success
}

@test "namespace label should have precedence" {
	run $prefix storageos $cliopts volume inspect "$NAMESPACE/$VOL2"
	echo $output | jq 'first.labels | contains({"no-repl":"true"})'
	echo $output | jq 'first.labels | contains({"storageos.feature.replicas":"1"}) | not'
}

@test "add same rule high priority in diff namespace" {
	run $rule_prefix create -n $NAMESPACE_WRONG --selector 'no-repl=true' --action add \
		--label namespace=different $NO_REPL_RULE_NAME
	assert_success
}

@test "update rule weigh (lower) and observe effect on volume" {
	run $rule_prefix update  -w 3 $FREPL_RULE_NAME
	assert_success
	run $vol_prefix create -n $NAMESPACE $VOL3
}

@test "deactivate rule, removes replication label" {
	run $rule_prefix update  --active=false $FREPL_RULE_NAME
	assert_success
	run $vol_prefix create -n $NAMESPACE $VOL4 --label 'repl=true'
	assert_success
}

@test "list rules" {
	run $rule_prefix ls
	assert_output --partial $NO_REPL_RULE_NAME
  assert_output --partial $REPL_RULE_NAME
}

@test "inspect rule" {
	run $rule_prefix inspect "$FREPL_RULE_NAME"
	echo $output | jq "first.name == \"$REPL_RULE_NAME\""
	echo $output | jq "first.namespace == \"$NAMESPACE\""
	echo $output | jq "first.weight == 10"
	echo $output | jq 'first.selector == "env=staging"'
}

@test "delete rules and volume" {
	run $rule_prefix rm $FNO_REPL_RULE_NAME
	assert_success
	run $rule_prefix rm $FREPL_RULE_NAME
	assert_success

	$prefix storageos $cliopts namespace rm $NAMESPACE_WRONG
	$prefix storageos $cliopts namespace rm $NAMESPACE
}
