
module "storageos_cluster-e3c44-0_8_1"  {
  source = "./cluster"
  do_token = "${var.do_token}"
  region="nyc1"
  tag="${var.tag}-e3c44-0_8_1"
  cluster_size="3"
  pvt_key_path="${var.pvt_key_path}"
  ubuntu_version="ubuntu-16-04-x64"
  cli_version="0.0.12"
  node_container_version="0.8.1"
  ssh_fingerprint="${digitalocean_ssh_key.default.fingerprint}" 
}

output "cluster_conn-e3c44-0_8_1" {
  value = "${module.storageos_cluster.ip-addrs}"
}




resource "null_resource" "copy-supervisor-config-e3c44-0_8_1" {
  count = 3

  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-e3c44-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }

    source = "/home/houssem/go/bin/runner"
    dest = "~/go/bin/runner"
  }

  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-e3c44-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }

    source = "./config/e3c44-0_8_1"
    dest = "~/e3c44-0_8_1"
  }

  provisioner "remote_exec" {

    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster-e3c44-0_8_1.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    
    inline = ["runner --jobs ~/e3c44-0_8_1"]
    
  }
}

