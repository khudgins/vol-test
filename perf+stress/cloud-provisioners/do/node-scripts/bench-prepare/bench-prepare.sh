#!/bin/bash

# it will be running once on every node before the benchmark
NODE_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

$NODE_SCRIPT_DIR/bench-prepare/benchmark_to_influxdb.sh

# $NODE_SCRIPT_DIR/bench-prepare/netbenchmark_to_influxdb.sh

