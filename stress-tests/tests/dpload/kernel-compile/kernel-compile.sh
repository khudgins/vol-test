#!/bin/bash

KERNEL_VERSION=linux-4.13.1.tar.xz
wget -O /data/kernel.tar.xz https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.13.1.tar.xz

pushd /data/
#need xz-utils potentially
tar -xJvf kernel.tar.xz

pushd $KERNEL_VERSION
  make oldconfig
  make -j 32 > /dev/null
popd

popd


