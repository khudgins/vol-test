# Setting up to test with DigitalOcean

## Configure DigitalOcean

### DigitalOcean login

You need a DigitalOcean login. Create one if you need to. You don't need any special permissions for StorageOS, a personal account is fine. They support 2FA, it works well.

### SSH key

Under settings (accessed via your profile picture), add an SSH public key. You'll use this to log into your created VMs, which they call 'droplets' because metaphor.

### Auth token

Under 'API', use 'Generate New Token' to do so. I created a token specific to the task, called `storageos-bats`. You'll want to save this somewhere, or use it directly in the client setup step later.

## Configure client workstation

### Install `doctl` client

On your client workstation, install `doctl`. On a Mac you can do this using Homebrew: `brew install doctl`. There are instruction for other platforms and building from source on their github [site](https://github.com/digitalocean/doctl).

### Install client tools

You need `httpie` and `jq`. On a Mac, `brew install httpie jq` is enough.

### Install BATS

There are instructions for installing BATS in the main `README.md` of this module. Nonetheless:

```
$ cd ~/git
$ git clone https://github.com/sstephenson/bats.git
...
$ cd bats
$ sudo ./install.sh /usr/local
```

### Update `vol-test` submodules

This module (`vol-test`) has submodules. Check they're ready.

```
$ git submodule init
$ git submodule update --recursive --remote
```

## Setup

### `doctl` token
On the client:

```
$ doctl auth init
DigitalOcean access token:
```

Enter your API authentication token here. You should get:

```
Validating token... OK
$
```

### SSH key

Set your ssh key fingerprint in `user_provision.sh` in the source directory (the same directory as `provision.sh`, probably the same directory as this document). Create `user_provision.sh` if necessary.

The key fingerprint can be found in the DO settings, it's not the key itself. Alternatively, you can get it from your key:

```
ssh-keygen -l -E md5 -f ~/.ssh/id_rsa.pub
2048 MD5:5b:2a:e0:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:79 2016-03-01 Default key <nope@ae-35.com> (RSA)
```

However you get the fingerprint, add it to `user_provision.sh`:

```
sshkey=5b:2a:e0:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:79
```

### Create Consul droplet

We need a KV store. It only needs to be a single node, but it must run separately to the test machines.

We'll install a single-node Consul 'cluster'.

This could be done a bunch of ways, here's how I did it. I used the GUI to create it. It could be automated, but it's a one-off.

'Create droplet', Ubuntu 16.04.2 x64, the base size is fine ($5/mo as I write).

No need to add storage or private networking.

Add the SSH key whose public component you uploaded earlier. It should be listed, if not you missed a step.

Set the name to something useful, I set 'consul-01'.

It'll take a minute or two for the machine to be built, and then you'll get an an IP address. Set it in `user_provision.sh`:

```
sshkey=5b:2a:e0:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:79
kv_addr=66.66.66.32:8500
```

### Install Consul

SSH to the droplet:

```
$ ssh root@66.66.66.32
Welcome to Ubuntu 16.04.2 LTS (GNU/Linux 4.4.0-72-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

11 packages can be updated.
0 updates are security updates.


Last login: Thu Apr 13 18:52:06 2017 from 213.205.198.228
root@consul-01:~#
```

How exciting. Now [download Consul](https://www.consul.io/downloads.html) from Hashicorp and extract to `/usr/local/bin/`:

```
# apt update
# apt install unzip curl
# curl -OL https://releases.hashicorp.com/consul/0.8.1/consul_0.8.1_linux_amd64.zip
# cd /usr/local/bin
# unzip ~/consul_0.8.1_linux_amd64.zip
# mkdir /etc/consul.d
```

Create `/etc/consul.d/config.json`:

```
{
  "client_addr": "0.0.0.0",
  "datacenter": "lon1",
  "data_dir": "/var/lib/consul/data",
  "log_level": "INFO",
  "server": true,
  "bootstrap_expect": 1
}
```

Create systemd unit file `/etc/systemd/system/consul.service`:

```
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/default/consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/consul agent $OPTIONS -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
```

Install the service:

```
# systemctl daemon-reload
# systemctl enable consul
# systemctl start consul

# systemctl status consul
● consul.service - consul agent
   Loaded: loaded (/etc/systemd/system/consul.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2017-04-21 10:43:02 UTC; 2min 16s ago
 Main PID: 2221 (consul)
    Tasks: 9
   Memory: 10.6M
      CPU: 1.034s
   CGroup: /system.slice/consul.service
           └─2221 /usr/local/bin/consul agent -config-dir=/etc/consul.d

Apr 21 10:43:02 consul-01 consul[2221]:     2017/04/21 10:43:02 [INFO] consul: Handled member-join event for server "consul-01.lon1"
Apr 21 10:43:02 consul-01 consul[2221]:     2017/04/21 10:43:02 [INFO] serf: Attempting re-join to previously known node: consul-01.
Apr 21 10:43:02 consul-01 consul[2221]:     2017/04/21 10:43:02 [INFO] serf: Re-joined to previously known node: consul-01.dc1: 10.1
Apr 21 10:43:07 consul-01 consul[2221]:     2017/04/21 10:43:07 [WARN] raft: Heartbeat timeout from "" reached, starting election
Apr 21 10:43:07 consul-01 consul[2221]:     2017/04/21 10:43:07 [INFO] raft: Node at 10.16.0.5:8300 [Candidate] entering Candidate s
Apr 21 10:43:07 consul-01 consul[2221]:     2017/04/21 10:43:07 [INFO] raft: Election won. Tally: 1
Apr 21 10:43:07 consul-01 consul[2221]:     2017/04/21 10:43:07 [INFO] raft: Node at 10.16.0.5:8300 [Leader] entering Leader state
Apr 21 10:43:07 consul-01 consul[2221]:     2017/04/21 10:43:07 [INFO] consul: cluster leadership acquired
Apr 21 10:43:07 consul-01 consul[2221]:     2017/04/21 10:43:07 [INFO] consul: New leader elected: consul-01
Apr 21 10:43:08 consul-01 consul[2221]:     2017/04/21 10:43:08 [INFO] agent: Synced node info
```

That's it. Yes, this could be Ansible-ised.

## Finalise setup

On the client, set the product version  in `user_provision.sh`:

```
version=0.7.7
kv_addr=66.66.66.32:8500
sshkey=5b:2a:e0:e2:f9:44:a2:41:81:90:42:22:57:3a:fd:79
```

## Provision and run the tests

### Provision machines

On the client:

```
$ ./provision.sh
Loading user settings overrides from user_provision.sh
Creating new droplets
Name        Droplet Count
vol-test    0
Waiting for SSH on 139.59.191.128

... lots of info ...

Clearing KV state
HTTP/1.1 200 OK
Content-Length: 4
Content-Type: application/json
Date: Fri, 21 Apr 2017 10:50:05 GMT

true


SUCCESS!  Ready to run tests:
  source test.env
  bats singlenode.bats
  bats secondnode.bats
  bats failnode.bats

```

### Run the tests

Those look like good instructions from the provisioner script.

```
$ source test.env
```

`test.env` sets environment variables for the test runs. It's constructed by `provision.sh` to match the environment you've created.

Run in the stated order.

```
$ bats singlenode.bats
✓ Test: Install plugin for driver (storageos/plugin:0.7.7)
✓ Test: Create volume using driver (storageos/plugin:0.7.7)
✓ Test: Confirm volume is created (volume ls) using driver (storageos/plugin:0.7.7)
✓ Test: Confirm docker volume inspect works using driver (storageos/plugin:0.7.7)
✓ Start a container and mount the volume
✓ Write a textfile to the volume
✓ Confirm textfile contents on the volume
✓ Create a binary file
✓ get a checksum for that binary file
✓ Confirm checksum
✓ Stop container
✓ Destroy container
✓ Let's see if our data is still here
✓ Confirm textfile contents are still on the volume
✓ Confirm checksum persistence
✓ Stop container
✓ Destroy container

17 tests, 0 failures
```

```
$ bats secondnode.bats
 ✓ Test: Install plugin for driver (storageos/plugin:0.7.7) on node 2
 ✓ Test: Confirm volume is visible on second node (volume ls) using driver (storageos/plugin:0.7.7)
 ✓ Start a container and mount the volume on node 2
 ✓ Confirm textfile contents on the volume from node 2
 ✓ Confirm checksum for binary file on node 2
 ✓ Stop container on node 2
 ✓ Destroy container on node 2
 ✓ Remove volume
 ✓ Confirm volume is removed from docker ls

9 tests, 0 failures
```

```
$ bats failnode.bats
 ✓ Create replicated volume using driver (storageos/plugin:0.7.7)
 ✓ Confirm volume is created (volume ls) using driver (storageos/plugin:0.7.7)
 ✓ Confirm volume has 1 replica using storageos cli
 ✓ Start a container and mount the volume on node 2
 ✓ Create a binary file
 ✓ Get a checksum for that binary file
 ✓ Confirm checksum on node 2
 ✓ Stop container on node 2
 ✓ Destroy container on node 2
 ✓ Stop storageos on node 2
 ✓ Wait 60 seconds
 ✓ Confirm checksum on node 1
 ✓ Re-start storageos on node 2

13 tests, 0 failures
```

Anything other than zero failures is bad.

## Re-running the tests

Re-run starting with the `provision.sh` step. It doesn't take that long to re-provision and it's completely automatic.

## Image refresh

We need a Docker-on-Ubuntu-16.04 image. Sometimes this gets updated and the existing `provision.sh` script will fail. I find the current image with:

```
$ doctl compute image list |grep docker
23219707    Docker 17.03.0-ce on 14.04                           snapshot    Ubuntu          docker                  true      20
24445730    Docker 17.04.0-ce on 16.04                           snapshot    Ubuntu          docker-16-04            true      20
```

We want the second one. Copy the first integer field into `provision.sh`:

```
... other definitions ...

image=24445730

...
```

This should unbreak provisioning runs.
