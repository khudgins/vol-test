## Introduction

vol-test is a set of integration tests that is intended to prove and test API support of volume plugins for Docker. vol-test is based upon BATS(https://github.com/sstephenson/bats.git) and depends on some helper libraries - bats-support and bats-assert which are linked as submodules.

vol-test supports testing against remote environments. Remote Docker hosts should have ssh keys configured for access without a password.

## Setup

- Install BATS.

    ```
    git clone https://github.com/sstephenson/bats.git
    cd bats
    sudo ./install.sh /usr/local
    ```

- Clone this repository (optionally, fork), and pull submodules

    ```
    git clone https://github.com/khudgins/vol-test
    cd vol-tests
    git submodule update --recursive --remote
    ```
- Install jq (on mac you can brew install it)

## Provisioning


### as a standalone run of the automated tests (currently in digital ocean):

### SSH key

Set your ssh key fingerprint in `user_provision.sh` in the source directory (the same directory as `provision.sh`, probably the same directory as this document). Create `user_provision.sh` if necessary.

The key fingerprint can be found in the DO settings, it's not the key itself. Alternatively, you can get it from your key:

```
ssh-keygen -l -E md5 -f ~/.ssh/id_rsa.pub
2048 MD5:5b:2a:e0:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:79 2016-03-01 Default key <nope@ae-35.com> (RSA)
```

However you get the fingerprint, add it to `user_provision.sh`:

```
SSHKEY=5b:2a:e0:de:ad:be:ef:de:ad:be:ef:de:ad:be:ef:79
```

### bootstrapping the cluster

Depending on whether machines need to be created from scratch in digital ocean also set `BOOTSTRAP` env variable and run `provision.sh` from top level directory.
You can check if the cluster has been built before or not by verifying are no machines tagged vol-test or consul-vol-test in the Digital Ocean shared account.

This will create 3 node cluster in digital ocean and a separate consul VM running a consul container.

On subsequent runs or if you can see that VMS with tags vol-test and consul-node are 
already created unset `BOOTSTRAP` and run `provision.sh` this will have the advantage of reusing the VMS and your tests will be quicker.

### as a Jenkins run:

When the script is run as part of a Jenkins run these vars have to be set:

1. A unique build number which will be used in tags passed through `BUILD` ENV variable
1. A `DO_KEY` env variable containing an API key for jenkins functional account in Digital Ocean
1. The md5 fingerprint of the JENKINS SSH key as 'SSHKEY' which should have been previously added to DO
1. `JENKINS_JOB` has to be set to "true"

You can also optionally set the 
`PLUGIN_NAME`, `VERSION` or `CLI_VERSION` environment variables for plugin name, version and CLI version
respectively.

This will recreate the cluster from scratch every time which currently takes a couple of minutes.

## Running

source the test.env script as prompted after provisioning, and then 
call ./run_volume_test.sh from the top level.

- Configuration:

vol-test requires a few environment variables to be configured before running:

* VOLDRIVER - this should be set to the full path (store/vendor/pluginname:tag) of the volume driver to be tested
* PLUGINOPTS - Gets appended to the 'docker volume install' command for install-time plugin configuration
* CREATEOPTS - Optional. Used in 'docker volume create' commands in testing to pass options to the driver being tested
* PREFIX - Optional. Commandline prefix for remote testing. Usually set to 'ssh address_of_node1'
* PREFIX2 - Optional. Commandline prefix for remote testing. Usually set to 'ssh address_of_node2'


- To validate a volume plugin:

1. Export the name of the plugin that is referenced when creating a network as the environmental variable `$VOLDRIVER`.
2. Run the bats tests by running `bats singlenode.bats secondnode.bats`

Example using the vieux/sshfs driver (replace `vieux/sshfs` with the name of the plugin/driver you wish to test):

Prior to running tests the first time, you'll want to pull all the BATS assist submodules, as well:
```
git submodule update --recursive --remote
```

```
$PREFIX="docker-machine ssh node1 "
$VOLDRIVER=vieux/sshfs
$CREATEOPTS="-o khudgins@192.168.99.1:~/tmp -o password=yourpw"

bats singlenode.bats

✓ Test: Create volume using driver (vieux/sshfs)
✓ Test: Confirm volume is created using driver (vieux/sshfs)
...

15 tests, 0 failures
```

## Destroying the cluster

Just run the './destroy.sh' script this will destroy all machines with the right tags.. 

You need to pass a build number and jenkins do token as well for appropriate jenkins cleanup

We assume that jenkins runs will be doing this at every run and recreating.
