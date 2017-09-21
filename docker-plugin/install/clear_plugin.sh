#!/bin/bash

# shellcheck disable=SC2086

driver=storageos

# shellcheck disable=SC1091 source=../../test.env
. ../../test.env

rm_plugin="docker plugin rm -f $driver"

$PREFIX $rm_plugin
$PREFIX2 $rm_plugin
$PREFIX3 $rm_plugin
