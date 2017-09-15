
resource "digitalocean_tag" "tag" {
  count = "${(length(var.tag) > 0)? 1 :0}"
  name = "${var.tag}"
}

# Template for INITIAL_CLUSTER configuration
data "template_file" "cluster_config" {
  template = "INITIAL_CLUSTER=${join(",", formatlist("%s=http://%s:5707", "${digitalocean_droplet.storageos-ubuntu.*.name}", "${digitalocean_droplet.storageos-ubuntu.*.ipv4_address}"))}"
}

resource "digitalocean_droplet" "storageos-ubuntu" {
  count = "${var.cluster_size}"
  name = "machine-${count.index}"
  region = "lon1"
  size = "2gb"
  image = "${var.ubuntu_version}"
  ssh_keys = [ 
       "${var.ssh_fingerprint}" 
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
    inline = ["export DEBIAN_FRONTEND=noninteractive", "apt -q -y clean", "apt -q -y update", "curl -fsSL get.docker.com -o get-docker.sh","sh get-docker.sh","sudo modprobe nbd nbds_max=1024",
    "echo 'options nbd nbds_max=1024' > /etc/modprobe.d/nbd.conf",
    "mkdir -p /var/lib/storageos",
    "curl -sSL https://github.com/storageos/go-cli/releases/download/${var.cli_version}/storageos_linux_amd64 > /usr/local/bin/storageos","chmod +x /usr/local/bin/storageos"]
  }
}

resource "null_resource" "run-storageOS" {
  count = 3

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    inline = [
      "echo INSTANCE_NUMBER=${count.index + 1}",
      "sudo docker run -d --name storageos -e HOSTNAME  -e ADVERTISE_IP=${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)} -e ${data.template_file.cluster_config.rendered}  --net=host  --pid=host --privileged  --cap-add SYS_ADMIN  --device /dev/fuse -v /var/lib/storageos:/var/lib/storageos:rshared -v /run/docker/plugins:/run/docker/plugins storageos/node:${var.node_container_version} server"]
  }
}

