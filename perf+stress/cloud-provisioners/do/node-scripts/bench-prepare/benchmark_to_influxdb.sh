#!/bin/bash -x

# NOTE:script copied and adapted from dataplane/scripts/benchmark_to_influxdb.sh

# Runs the main benchmarks and inserts the results into influxdb_output
: ${THREADS:=2}
: ${MAX_TEST_SECONDS:=10}
: ${INFLUXDB_DB:=benchmark}
: ${BUILD_NUMBER:=0}

BENCH_BINARY=/usr/local/bin/storageos_bench
if [ ! -x $BENCH_BINARY ]; then
  echo $BENCH_BINARY not found, exiting.
  exit 1
fi

# Set build to Jenkins build number (if present in env)
BUILD_PARAM=""
if [ -n "${BUILD_NUMBER}" -a ${BUILD_NUMBER} -gt 0 ]; then
  BUILD_PARAM="-b ${BUILD_NUMBER}"
fi

OUTPUT=storageos_bench.out.$$
for btype in dedupe compress compressz decompress crypto; do
  $BENCH_BINARY --influxdb -j $THREADS -s $MAX_TEST_SECONDS $BUILD_PARAM $btype >>$OUTPUT
  ipcrm -M 0x50500001 || true
  ipcrm -M 0x505fffff || true
done
cat $OUTPUT
curl -i -XPOST "${INFLUX_CONN}/write?db=${INFLUXDB_DB}" --data-binary "@${OUTPUT}"

rm $OUTPUT
