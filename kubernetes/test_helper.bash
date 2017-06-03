#!/usr/bin/env bats

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

load "$DIR/../test/test_helper/bats-support/load.bash"
load "$DIR/../test/test_helper/bats-assert/load.bash"

cliopts="-u new-user -p new-pass"

kubectl="/home/houssem/code/kubernetes/cluster/kubectl.sh"
jq="/usr/bin/jq"

export KUBERNETES_PROVIDER=local

$kubectl config set-cluster local --server=https://localhost:6443 --certificate-authority=/var/run/kubernetes/server-ca.crt > /dev/null
$kubectl config set-credentials myself --client-key=/var/run/kubernetes/client-admin.key --client-certificate=/var/run/kubernetes/client-admin.crt > /dev/null
$kubectl config set-context local --cluster=local --user=myself > /dev/null
$kubectl config use-context local > /dev/null

