This installs dynamic library dependencies required for storageos_benchmark.sh

based on:
http://code.storageos.net/projects/DKR/repos/build/browse/install-deps.sh

As you can see from the bundled downloaded from the build-deps job, ubuntu 16.04 is supported
we symlink 17 to 16 since the libraries have been tested to be compatible with 17, 
whatever (arch) you support you would need to add the appropriate bundle to benchmark.

