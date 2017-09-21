[Unit]
Description=StorageOS
Wants=network-online.target
After=network-online.target
After=docker.service
Requires=docker.service
Requires=td-agent-bit.service

[Service]
TimeoutStartSec=0
EnvironmentFile=/etc/default/storageos
ExecStartPre=-/usr/bin/docker kill storageos
ExecStartPre=-/usr/bin/docker rm storageos
ExecStartPre=/usr/bin/docker pull ${docker_image}
ExecStart=/usr/bin/docker run --log-driver=fluentd --name storageos -e HOSTNAME -e ADVERTISE_IP -e INITIAL_CLUSTER --net=host --pid=host --privileged --cap-add SYS_ADMIN --device /dev/fuse -v /var/lib/storageos:/var/lib/storageos:rshared -v /run/docker/plugins:/run/docker/plugins ${docker_image} server
ExecStop=/usr/bin/docker stop storageos

[Install]
WantedBy=default.target