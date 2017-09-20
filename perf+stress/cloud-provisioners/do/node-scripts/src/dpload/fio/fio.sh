#!/bin/bash -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FILENAME=$1
shift

if [[ -z $BENCH ]]; then
sudo fio --output-format=json $SCRIPT_DIR/$FILENAME $@
else
sudo -E fio --output-format=json $SCRIPT_DIR/$FILENAME $@ | fiord influxdb --uri $INFLUX_CONN --db=fio
fi
