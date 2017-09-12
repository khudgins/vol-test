#!/bin/bash -ex

sudo docker run -v $HOSTNAME:/data soegarots/kernel-compile:0.0.2
