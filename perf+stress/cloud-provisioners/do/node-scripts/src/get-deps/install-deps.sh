#!/bin/bash

# Currently only ubuntu 16 is supported, drop in the right bundle to add support for different arch
set -e -u

function error() {
    echo "ERROR: $*" >&2
    exit 1
}

function info() {
    echo "INFO: $*"
}

os="$(uname)"
if [ -z "$os" ]; then
    error "Couldn't identify OS"
fi

if [ $os = Linux ]; then
    if ! lsb_release -a >/dev/null 2>&1; then
        error "lsb_release must be installed!"
    fi
    plat="$(echo "$(lsb_release -is)-$(lsb_release -rs)" | tr '[:upper:]' '[:lower:]' )"
else
    error "dataplane artefacts currently built for unix only"    
fi

machine="$(uname -m)"
arch=${plat}-${machine}
info "Setting arch=$arch"

bundle_file="Bundle-latest-${arch}.tar.gz"

mkdir -p /opt/storageos

info "Installing"
tar -C /opt/storageos -xf $bundle_file
if [ -f /opt/storageos/.scripts/after_install ]; then
    info "Running after_install script"
    /opt/storageos/.scripts/after_install
fi
