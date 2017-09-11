
module "storageos_cluster-low-0_8_1"  {
  source = "./cluster"
  do_token = "${var.do_token}"
  region="nyc1"
  tag="${var.tag}-low-0_8_1"
  cluster_size="3"
  pvt_key_path="${var.pvt_key_path}"
  ubuntu_version="ubuntu-16-04-x64"
  cli_version="0.0.12"
  node_container_version="0.8.1"
  ssh_fingerprint="${digitalocean_ssh_key.default.fingerprint}" 
}

output "cluster_conn-low-0_8_1" {
  value = "${module.storageos_cluster-low-0_8_1.ip-addrs}"
}

resource "null_resource" "copy-supervisor-config-low-0_8_1" {
  count = 3

  /* copy the runner binary */ 
  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-low-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }

    source = "/home/houssem/code/vol-test/stress-tests/cloud-provisioners/do/scripts/../bin/runner"
    destination = "/usr/local/bin/runner"
  }

  /* copy the job config binary */ 
  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-low-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }

    source = "./configs/low-0_8_1"
    destination = "~/low-0_8_1"
  }
  
  /* copy systemd file */
  
  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-low-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    
    source = "./configs/low-0_8_1.service"
    destination = "/etc/systemd/system/low-0_8_1.service"
  }

  /*copy scripts for jobs */
  
  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-low-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }

    source = "./node-scripts"
    destination = "~/"
  }

  provisioner "remote-exec" {

    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-low-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    
    inline = ["chmod +x /usr/local/bin/runner ~/node-scripts/**  &&  systemctl enable low-0_8_1 --now"]
    
  }
}

