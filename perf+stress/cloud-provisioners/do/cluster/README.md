StorageOS cluster

The terraform cluster here installs a variable size ubuntu cluster with the storageos/node container.
It assumes that you have added the SSH key to that you want to use to digital ocean through API or web console,
This key is used to connect to the machines and you are asked to supply the private_key path to it and the md5 ssh fingerprint.
You can compute this `ssh-keygen -lf pubkey`
Configuration also requires a digital ocean token for setting up the provider. you can also add an optional tag for your machines, these machines will be named machine-x where x is your position in the cluster.

We tend to instantiate these as terraform modules and add our own customisations on top..
