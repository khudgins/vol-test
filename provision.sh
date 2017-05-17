#!/bin/bash

set +e
declare -a ips

plugin_name="${PLUGIN_NAME:-soegarots/plugin}"
version="${VERSION:-latest}"
cli_version="${CLI_VERSION:-0.0.5}"
kv_addr=138.68.188.68:8500
tag="vol-test${BUILD:+-$BUILD}"
region=lon1
image=$(doctl compute image list  | grep docker-16-04 | awk '{ print $1 }') # ubuntu on linux img
size=2gb
sshkey="$JENKINS_KEY"
name_template="${tag}-${size}-${region}"
consul_vm_tag="${tag}-consul"


if [[ -f user_provision.sh ]] && [[  -z "$JENKINS_JOB" ]]; then
    echo "Loading user settings overrides from user_provision.sh"
    . ./user_provision.sh
fi

function download_storageos_cli()
{
  export cli_binary=storageos_linux_amd64-${cli_version}

  if [[ ! -f $cli_binary ]]; then
    curl -sSL https://github.com/storageos/go-cli/releases/download/v${cli_version}/storageos_linux_amd64 > $cli_binary
    chmod +x $cli_binary
  fi
}

function provision_do_nodes()
{
  droplets=$(doctl compute droplet list --tag-name ${tag} --format ID --no-header)

  if [[ -z "${droplets}" ]] || [[ -n "$JENKINS_JOB" ]] || [[ -n $BOOTSTRAP  ]]; then
    echo "Creating new droplets"
    doctl compute tag create $tag
    for name in ${name_template}01 ${name_template}02 ${name_template}03; do
      id=$(doctl compute droplet create \
        --image $image \
        --region $region \
        --size $size \
        --ssh-keys $SSHKEY \
        --tag-name $tag \
        --format ID \
        --no-header $name)
      droplets+=" ${id}"
    done
  else
    for droplet in $droplets; do
      echo "Rebuilding existing droplet ${droplet}"
      doctl compute droplet-action rebuild "$droplet" --image $image
    done
  fi

  for droplet in $droplets; do

    while [[ "$status" != "active" ]]; do
      sleep 2
      status=$(doctl compute droplet get "$droplet" --format Status --no-header)
    done

    ip=$(doctl compute droplet get "$droplet" --format PublicIPv4 --no-header)
    ips+=($ip)

    echo "Waiting for SSH on $ip"
    until nc -zw 1 "$ip" 22; do
      sleep 2
    done
    sleep 5

    ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
    echo "Disabling firewall"
    until ssh "root@${ip}" "/usr/sbin/ufw disable"; do
      sleep 2
    done

    echo "Enabling core dumps"
    ssh "root@${ip}" "echo ulimit -c unlimited >/etc/profile.d/core_ulimit.sh"
    ssh "root@${ip}" "export DEBIAN_FRONTEND=noninteractive ; apt-get update ; apt-get -qqqy install systemd-coredump"

    echo "Copying StorageOS CLI"
    scp -p $cli_binary root@${ip}:/usr/local/bin/storageos
    ssh root@${ip} "echo export STORAGEOS_USERNAME=storageos >>/root/.bashrc"
    ssh root@${ip} "echo export STORAGEOS_PASSWORD=storageos >>/root/.bashrc"

    echo "Setting up for core dumps"
    ssh root@${ip} "echo ulimit -c unlimited >/etc/profile.d/core_ulimit.sh"
    ssh root@${ip} "export DEBIAN_FRONTEND=noninteractive ; apt-get update ; apt-get -qqy install systemd-coredump"

    echo "Enable NBD"
    ssh root@${ip} "modprobe nbd nbds_max=1024"
  done
}


function provision_consul() {
  if [[ -n "$JENKINS_JOB" ]] || [[ -n $BOOTSTRAP ]] ; then
    doctl compute tag create $consul_vm_tag

    id=$(doctl compute droplet create \
      --image $image \
      --region $region \
      --size 512mb \
      --ssh-keys $SSHKEY \
      --tag-name $consul_vm_tag \
      --format ID \
      --no-header "consul-node")

    ip=$(doctl compute droplet get "$id" --format PublicIPv4 --no-header)

    echo "Waiting for SSH on $ip"
    until nc -zw 1 "$ip" 22; do
      sleep 2
    done
    sleep 5

    ssh-keyscan -t ecdsa -H "$ip" >> ~/.ssh/known_hosts
    ssh root@$ip 'docker run --name consul-single-node -d -p 8500:8500 -p 8600:53/udp -h consul-node progrium/consul -server -bootstrap'

  else
    id=$(doctl compute droplet list --format ID --no-header --tag-name $consul_vm_tag)

    ssh-keyscan -t ecdsa -H "$ip" >> ~/.ssh/known_hosts

    ip=$(doctl compute droplet get "$id" --format PublicIPv4 --no-header)
    ssh root@$ip 'docker stop consul-single-node'
    ssh root@$ip 'docker rm consul-single-node'
    ssh root@$ip 'docker run --name consul-single-node -d -p 8500:8500 -p 8600:53/udp -h consul-node progrium/consul -server -bootstrap'
  fi

  kv_addr="$ip:8500"

}

function do_auth_init()
{
  doctl auth init <<< $DO_TOKEN
}

function MAIN()
{
  set -x
  do_auth_init
  download_storageos_cli
  provision_consul
  provision_do_nodes
  write_config
  set +x
}

function write_config()
{
  echo "Clearing KV state"
  [[ -n "$kv_addr" ]] && http delete ${kv_addr}/v1/kv/storageos?recurse

cat << EOF > test.env
export VOLDRIVER="${plugin_name}:${version}"
export PLUGINOPTS="KV_ADDR=${kv_addr}"
export CLIOPTS="-u storageos -p storageos"
export KV_ADDR="${kv_addr}"
export PREFIX="ssh root@${ips[0]}"
export PREFIX2="ssh root@${ips[1]}"
export PREFIX3="ssh root@${ips[2]}"
EOF

  echo "SUCCESS!  Ready to run tests:"
  echo "  source test.env"
  echo "  ./run-volume-tests.sh"
}

MAIN
