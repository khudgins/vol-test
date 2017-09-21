
resource "digitalocean_tag" "tag" {
  count = "${(length(var.tag) > 0)? 1 :0}"
  name = "${var.tag}"
}

# Template for INITIAL_CLUSTER configuration
data "template_file" "cluster_config" {
  template = "${join(",", formatlist("%s=http://%s:5707", "${digitalocean_droplet.storageos-ubuntu.*.name}", "${digitalocean_droplet.storageos-ubuntu.*.ipv4_address}"))}"
}

data "template_file" "storageos-service" {
  template = "${file("./files/storageos.service.tpl")}"

  vars {
    docker_image = "storageos/node:${var.node_container_version}"
  }
}

resource "digitalocean_droplet" "storageos-ubuntu" {
  count = "${var.cluster_size}"
  name = "${var.machine_prefix}-${count.index}"
  region = "lon1"
  size = "${var.machine_size}"
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
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt -q -y clean",
      "apt -q -y update",
      "curl -fsSL get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "sudo modprobe nbd nbds_max=1024",
      "echo 'options nbd nbds_max=1024' > /etc/modprobe.d/nbd.conf",
      "mkdir -p /var/lib/storageos",
      "curl -sSL https://github.com/storageos/go-cli/releases/download/${var.cli_version}/storageos_linux_amd64 > /usr/local/bin/storageos",
      "chmod +x /usr/local/bin/storageos"
    ]
  }
}

resource "null_resource" "install-apps" {

  count = 3

  # Fluent Bit install
  provisioner "file" {
    connection {
      type = "ssh"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    content = "deb http://packages.fluentbit.io/ubuntu xenial main"
    destination = "/etc/apt/sources.list.d/fluentbit.list"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    inline = [
      "wget -qO - http://packages.fluentbit.io/fluentbit.key | sudo apt-key add -",
      "apt -q -y update",
      "DEBIAN_FRONTEND=noninteractive apt -q -y install td-agent-bit"
    ]
  }

  provisioner "file" {
    connection {
      type = "ssh"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    source = "./files/td-agent-bit.conf"
    destination = "/etc/td-agent-bit/td-agent-bit.conf"
  }

  provisioner "file" {
    connection {
      type = "ssh"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    source = "./files/td-agent-bit.service"
    destination = "/etc/systemd/system/td-agent-bit.service"
  }

  provisioner "file" {
    connection {
      type = "ssh"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    content = <<EOF
HOSTNAME="${element(digitalocean_droplet.storageos-ubuntu.*.name , count.index)}"
ADVERTISE_IP="${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
INITIAL_CLUSTER=${data.template_file.cluster_config.rendered}
EOF
    destination = "/etc/default/storageos"
  }

  provisioner "file" {
    connection {
      type = "ssh"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    content = "${data.template_file.storageos-service.rendered}"
    destination = "/etc/systemd/system/storageos.service"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(digitalocean_droplet.storageos-ubuntu.*.ipv4_address , count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    inline = [
      "systemctl daemon-reload",
      "systemctl enable storageos --now",
    ]
  }

}
