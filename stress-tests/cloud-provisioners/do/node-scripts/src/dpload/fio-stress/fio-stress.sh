#!/bin/bash -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FILENAME=$1
shift
sudo fio --output-format=json $SCRIPT_DIR/$FILENAME $@ #| fiord influxdb --uri http://127.0.0.1:8086 --db=fio

