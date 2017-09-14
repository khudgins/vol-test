FROM ubuntu:xenial
WORKDIR /TMP

RUN export DEBIAN_FRONTEND=noninteractive ;  apt-get update;  apt-get install -y --no-install-recommends build-essential xz-utils wget bc ca-certificates && update-ca-certificates

COPY kernel-compile.sh .

ENTRYPOINT ["./kernel-compile.sh"]
 
