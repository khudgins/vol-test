* Updated tests with secrets

- make your your cluster is up (hack/local_cluster_up.sh)
- run a standalone consul with 'docker run --name consul-single-node -d -p 8500:8500 -p 8600:53/udp -h consul-node progrium/consul -server --bootstrap-expect=1'
- run storageos locally './storageos.sh' (this storageos instance is configured with username: 'new-user' password: 'new-pass'
- change kubectl directory in 'test_helper.bash' to the directory in local_cluster_up
- export $kubectl=(KUBECTL_PATH) in your terminal for convenience
- run '$kubectl create -f examples/storageos-secret.yaml'
- run '$kubectl create -f bad-secrests/examples/storageos-secret.yaml'
- run the bats tests the three tests at top level are happy path tests that use TOP/example/ and should work, the bad test is under 'bad-secrets/' and uses TOP/bad-secrets/bad-examples ( not quite finished)


