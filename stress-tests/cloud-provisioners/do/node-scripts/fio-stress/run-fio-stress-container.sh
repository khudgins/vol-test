
#!/bin/bash -x

# this script will be continually executed from the runner
# it will be running on every node

voluid=$(uuidgen | cut -c1-5)

# waiting for controller to be healthy..
sleep 30

CREDS="-u storageos -p storageos"
storageos $CREDS volume create $voluid

#?

storageos $CREDS volume rm default/$voluid


