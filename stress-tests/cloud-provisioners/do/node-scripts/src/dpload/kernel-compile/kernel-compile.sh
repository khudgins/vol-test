#!/bin/bash

KERNEL_VERSION=linux-4.13.1
wget -O /data/kernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v4.x/$KERNEL_VERSION.tar.xz

pushd /data/
#need xz-utils potentially
tar -xJvf kernel.tar.xz

pushd $KERNEL_VERSION
  make clean
  make defconfig
  make -j 8 
popd
popd

