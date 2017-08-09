#!/bin/bash

# shellcheck disable=SC2086

driver=notset

# shellcheck disable=SC1091 source=../../test.env
. ../../test.sh

rm_plugin="docker plugin rm $driver"

$PREFIX $rm_plugin
$PREFIX2 $rm_plugin
$PREFIX3 $rm_plugin
