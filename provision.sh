#!/bin/bash

set +e
declare -a ips

plugin_name="${PLUGIN_NAME:-soegarots/plugin}"
version="${VERSION:-latest}"
cli_version="${CLI_VERSION:-0.0.5}"
tag="vol-test${BUILD:+-$BUILD}"
region=lon1
size=2gb
name_template="${tag}-${size}-${region}"


if [[ -f user_provision.sh ]] && [[  -z "$JENKINS_JOB" ]]; then
    echo "Loading user settings overrides from user_provision.sh"
    . ./user_provision.sh
fi

function download_storageos_cli()
{
  export cli_binary=storageos_linux_amd64-${cli_version}

  if [[ ! -f $cli_binary ]]; then
    curl -sSL "https://github.com/storageos/go-cli/releases/download/v${cli_version}/storageos_linux_amd64" > "$cli_binary"
    chmod +x "$cli_binary"
  fi
}

function provision_do_nodes()
{
  droplets=$($doctl_auth compute droplet list --tag-name ${tag} --format ID --no-header)

  if [[ -z "${droplets}" ]] || [[ -n "$JENKINS_JOB" ]] || [[ -n $BOOTSTRAP  ]]; then
    echo "Creating new droplets"
    $doctl_auth compute tag create $tag
    for name in ${name_template}01 ${name_template}02 ${name_template}03; do
      id=$($doctl_auth compute droplet create \
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
      $doctl_auth compute droplet-action rebuild "$droplet" --image $image
    done
  fi

  for droplet in $droplets; do

    while [[ "$status" != "active" ]]; do
      sleep 2
      status=$($doctl_auth compute droplet get "$droplet" --format Status --no-header)
    done

    sleep 5
    ip=$($doctl_auth compute droplet get "$droplet" --format PublicIPv4 --no-header)
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

function do_auth_init()
{

  # WE DO NOT MAKE USE OF DOCTL AUTH INIT but rather append the token to every request
  # this is because in a non-interactive jenkins job, any way of passing input (Heredoc, redirection) are ignored
  # with an 'unknown terminal' error we instead alias doctl and use the -t option everywhere
  export doctl_auth

  if [[ -z $DO_TOKEN ]] ; then
    echo "please ensure that your DO_TOKEN is entered in user_provision.sh"
    exit 1
  fi

  doctl_auth="doctl -t $DO_TOKEN"

  export image
  image=$($doctl_auth compute image list --public  | grep docker-16-04 | awk '{ print $1 }') # ubuntu on linux img
}

function write_config()
{
  echo "Clearing KV state"
  [[ -n "$kv_addr" ]] && [[ -z "JENKINS_JOB" ]] && http delete "${kv_addr}/v1/kv/storageos?recurse"

cat << EOF > test.env
export VOLDRIVER="${plugin_name}:${version}"
export PLUGINOPTS="KV_ADDR=${kv_addr}"
export CLIOPTS="-u storageos -p storageos"
export KV_ADDR="${kv_addr}"
export PREFIX="ssh root@${ips[0]}"
export PREFIX2="ssh root@${ips[1]}"
export PREFIX3="ssh root@${ips[2]}"
export DO_TAG="${tag}"
EOF

  echo "SUCCESS!  Ready to run tests:"
  echo "  ./run-volume-tests.sh"
  echo " Your environment credentials will be in test.env .. you may source it to interact with it manually"

}

function MAIN()
{
  set -x
  do_auth_init
  download_storageos_cli
  provision_do_nodes
  set +x
  write_config
}


MAIN
