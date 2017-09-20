#!/bin/bash

# Runs the main benchmarks and inserts the results into influxdb_output
: ${INFLUXDB_DB:=bench}
: ${BUILD_NUMBER:=0}

CREDS="-u storageos -p storageos"

# it will be running once on every node
NODE_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

OTHER_NODE=$(storageos  node ls | tail -n +2 | grep -v `hostname` | storageos node ls | awk '{ print $2 }')




curl -i -XPOST "${INFLUX_CONN}/write?db=${INFLUXDB_DB}" --data-binary "@${OUTPUT}"


