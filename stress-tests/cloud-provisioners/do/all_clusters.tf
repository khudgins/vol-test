
module "storageos_cluster"  {
  source = "./cluster"
  do_token = "${var.do_token}"
  region="nyc1"
  tag="${var.tag}"
  cluster_id="${var.cluster_id}"
  cluster_size="3"
  pub_key="${var.pub_key}"
  pvt_key_path="${var.pvt_key_path}"
  ubuntu-version="ubuntu-16-04-x64"

}

output "cluster_conn" {
  value = "${module.storageos_cluster.ip-addrs}"
}


resource "null_resource" "copy-stress-tests" {
  count = 3

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = "${element(module.storageos_cluster.ip-addrs, count.index)}"
      private_key = "${file(var.pvt_key_path)}"
      timeout = "10s"
    }
    inline = [
      "echo INSTANCE_NUMBER=${count.index + 1}",
      "docker run hello-world"
    ]
  }
}
