# Stress tests 'framework'

The Job runner allows to provision stress tests on top of regular storageos clusters.
They are run through the runner [code](http://code.storageos.net/projects/TOOL/repos/runner/browse)


When the pipeline is running it's entrypoint is './run-kernel-compile.sh', this is fed the env variables in `envfile.sh`
configuring the IAAS for the stress tests, a pre-set setting of stress tests (low medium high) and whether the tests are run 
in containers or on the host straight..

## How it works

Note: since bash doesn't offer 'modular' programming, code organisation is done through conventions regarding folders:

- Each IAAS provider has a folder under `TLD/cloud-provisioners` (currently only '/do'), This folder must have a `scripts/new-cluster.sh` script 
which manages the configuration of stress test clusters within its `/do` folder, this is currently done with a minimal layer of templating on top of terraform modules. 

Our `TLD/tests/` directory contains the source script for stress tests as well as Dockerfiles for them, we assume in our stress tests (both in host and container) that the /datdirectory is the storageos volume mount point both in container or on the host. 

The runner job config is the same for a particular cluster at a particular stress test level (eg `low`) and this config is run on every node using the runner and systemd.

We fix all stress test clusters to be 3 node clusters, this is easy to reconfigure in the `TLD/cloud-providers/templates/cluster.template`

## conventions for development

In the following text, when we refer to TLD we mean top level directory `vol-test/stress-tests` , `DODIR` refer to `TLD/cloudprovisioenrs/do` and `$LEVEL` a stress test level used when triggering the tests.
 
Although the following conventions are not strictly enforced (you are free within an IAAS implementation) it will be relevant if your provider is using terraform (with modules)
and to understand the digital ocean IAAS in `DODIR`.

- In the `DODIR/cluster` folder you can see that we implemented a vanilla storageos cluster installation, see its documentation for more details. this is a win because these eventually can be community guides for each provider and we can fetch them over git with `terraform get`

- When the `DODIR/new-cluster` script is triggered, provided this is a new cluster, we copy the job level from either `DODIR/jobs/container/$LEVEL` or `DODIR/jobs/host/$LEVEL` into the `configs/` folder. This config marks the existence of a new cluster (since state is essentially shared in pipeline through git).

- we then run a template processing step with the env variables supplied, this instantiate the vanilla module with specific config (see `DODIR/variables.tf` and the `DODIR/scripts/new-cluster.sh`) this generates a unique teraform module instance and terraform applies it.
our terraform workspace is the `DODIR` folder in that case.. we also add the `DODIR/provider.tf` on top of the clusters to create the key in digital ocean since this needs to be done once for all clusters. at any point the terraform source for all clusters is containes in files named: `DODIR/$LEVEL-STORAGEOS_VERSION.tf`

- The templates/ directory in each IAAS contains `lib/bash-tempalter` templates, this is used to overcome shortcomings in terraform multi-modules. it generates the terraform sources for each cluster and the `DODIR/configs/$LEVEL-STORAGEOS_VERSION.service` systemd runner script.

- We copy the `node-scripts` directory (which will be scripts invoked by the runner)

It also contains systemd tempaltes which we use to add node restart behaviour to our runner.

- our terraform template for each cluster adds instantiatiation of the module, copies runner, config , scripts and systemd unit and triggers the systemdunit.
the vanilla cluster has no logic that is specific to `stress-tests`


the `node-scripts` directory (which is copied to every node) usually hard-links
the script at the top-level (to avoid duplication/synch issues).

