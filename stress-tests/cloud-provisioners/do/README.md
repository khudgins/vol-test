This directory contains provisioning script and is the terraform workspace for the
terraform configuration that contains all the stress-test clusters..

As explained in the Top level readme. tempaltes in `templates/` are rendered to generate cluster configuration
from `./cluster` module and runner configuration.

When developing we are using the temp-key in `keys/` in jenkins, this will be the jenkins key..

You can use `script/destroy-all.sh` script to clear the cluster state when developing.


