#!/bin/bash

pushd $(tempdir)
curl -sSLO https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.13.tar.sign
gpg --import --keyid-format
popd


