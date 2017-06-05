#!/bin/bash

storage_version=latest

cli_version=0.0.4
cli_binary=/usr/local/bin/storageos
if [ ! -f $cli_binary ]; then
  curl -sSL https://github.com/storageos/go-cli/releases/download/v${cli_version}/storageos_linux_amd64 > $cli_binary
  chmod +x $cli_binary
fi

[ -d /var/lib/storageos ] || sudo mkdir /var/lib/storageos
[ -d /etc/docker/plugins ] || sudo mkdir -p /etc/docker/plugins
[ -f /etc/docker/plugins/storageos.json ] ||  sudo wget -O /etc/docker/plugins/storageos.json https://docs.storageos.com/assets/storageos.json

sudo modprobe nbd nbds_max=1024
docker rm -f storageos
docker run -d --name storageos \
	-e HOSTNAME \
	-e ADMIN_USERNAME=new-user \
	-e ADMIN_PASSWORD=new-pass \
	--net=host \
	--pid=host \
	--privileged \
	--cap-add SYS_ADMIN \
	--device /dev/fuse \
	-v /var/lib/storageos:/var/lib/storageos:rshared \
	-v /run/docker/plugins:/run/docker/plugins \
	storageos/node:$storage_version server


