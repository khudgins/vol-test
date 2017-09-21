
This directory contains provisioning script and is the terraform workspace for the
terraform configuration that generates the stress-test cluster

As explained in the Top level readme. tempaltes in `templates/` are rendered to generate cluster configuration
from `./cluster` module and runner configuration.

When developing we are using the temp-key in `keys/` in jenkins, this will be the jenkins key..

You can use `script/destroy-all.sh` script to clear the cluster state when developing.


The reason we use templating is the following issue : No count on modules:

https://github.com/hashicorp/terraform/issues/953 

THE UID's should be unique to avoid state synchronisation issues..
