
resource "digitalocean_tag" "tag" {
  count = "${(length(var.tag) > 0)? 1 :0}"
  name = "${var.tag}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "storageos ssh key"
  public_key = "${file(var.pub_key)}"
}

resource "digitalocean_droplet" "storageos-ubuntu" {
  count = "${var.cluster_size}"
  name = "machine-${count.index}"
  region = "lon1"
  size = "2gb"
  image = "${var.ubuntu-version}"
  ssh_keys = [ 
       "${digitalocean_ssh_key.default.fingerprint}" 
     ] 
  tags = ["${digitalocean_tag.tag.id}"]
  private_networking = true

  connection {
    user = "root"
    type = "ssh"
    private_key = "${file(var.pvt_key_path)}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = ["curl -fsSL get.docker.com -o get-docker.sh","sh get-docker.sh","sudo modprobe nbd nbds_max=1024",
    "echo 'options nbd nbds_max=1024' > /etc/modprobe.d/nbd.conf",
    "mkdir -p /var/lib/storageos", "docker run -d --name storageos -e HOSTNAME  -e ADVERTISE_IP=${self.ipv4_address_private} -e CLUSTER_ID=${var.cluster_id}  --net=host  --pid=host --privileged  --cap-add SYS_ADMIN  --device /dev/fuse -v /var/lib/storageos:/var/lib/storageos:rshared -v /run/docker/plugins:/run/docker/plugins  storageos/node server"]

  }
}
