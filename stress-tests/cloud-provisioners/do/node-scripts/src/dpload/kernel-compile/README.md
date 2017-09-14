This is the stress test job definition for kernel-compile

this scripts which is run inside docker image pulls the linux kernel into the storageos volume
and compiles it using the defaults.

For reusability, there is a hard link to the script for the host job in `DODIR/node-scripts/` 


