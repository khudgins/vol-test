Kernel compile test:

This test downloads the 4.13 kernel into `/data` (both in host and container)  untars it and compiles it.

this test suites illustrates nicely how we can reuse functionality in the kernel-compile container and host suite.
You will see that the kernel compile script in `src/dpload/fio-stress.sh` is called directly after manually mounting the disk and in the container 
case this is the exact same script bundled in the dockerfile and we let docker mount the volume for us in the fixed `/data/` location
