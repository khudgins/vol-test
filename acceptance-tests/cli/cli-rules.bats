#!/usr/bin/env bats

load ../../test_helper

export NAMESPACE=test

export REPL_RULE_NAME='replicator'
export FRULE_NAME="$NAMESPACE/$RULE_NAME"

export NO_REPL_RULE_NAME='de-replicator'
export FNO_REPL_RULE_NAME="$NAMESPACE/$RULE_NAME"

export VOL_NAME='rule-test-volume'
export FVOL_NAME="$NAMESPACE/$VOL_NAME"

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

@test "add norepl label to $NAMESPACE namespace" {
	run $prefix storageos $cliopts namespace update $NAMESPACE --label-add "no-repl=true"
	assert_success
}

@test "create volume in namespace $NAMESPACE, rule is applied" {
}

@test "create test volume in $NAMESPACE namespace with repl=true label" {
	run $vol_prefix create -n $NAMESPACE $VOL_NAME --label 'repl=true'
	assert_success
}

@test "namespace rule has precedence?" {
	run $prefix storageos $cliopts volume inspect $FVOL_NAME
	echo $output | jq '"no-repl=true" in first.labels'
}

@test "add same rule high priority in diff namespace (no effect)" {
	run $rule_prefix create -n test2 -w 10 --selector 'no-repl=true' --action add \
		--label test=veryyes \'MEANINGLESS RULE\'
	assert_success
	run $prefix storageos $
}

@test "create label for specific volume in namespace, lower weight" {
	run $rule_prefix update $FREPL_RULE_NAME -w 3
	assert_success
	run $vol_prefix create -n $NAMESPACE ${VOL_NAME}-2 ${F_VOL_NAME}-2
}

@test "deactivate rule, removes replication label" {
	run $rule_prefix update $FRULE_NAME --active false
	assert_success
	run $vol_prefix create -n $NAMESPACE ${VOL_NAME}-3 --label 'repl=true'
	assert_success
}

# @test "list rules" {
# 	run $rule_prefix ls
# 	assert_output --partial $FNAME
#   assert_output --partial 'storageos.feature.replicas=1'
# }

@test "inspect rule" {
	run $rule_prefix inspect "$FNAME"
	echo $output | jq "first.name == $RULE_NAME"
	echo $output | jq "first.namespace == $NAMESPACE"
	echo $output | jq "first.weight == 10"
	echo $output | jq 'first.selector == "env=staging"'
}

@test "delete rules and volume" {
	run $rule_prefix rm $FNO_REPL_RULE_NAME
	assert_success

	$vol_prefix rm $FVOL_NAME
	$vol_prefix rm $FVOL_NAME-2
	$vol_prefix rm $FVOL_NAME-3
	$prefix namespace rm test2
}
