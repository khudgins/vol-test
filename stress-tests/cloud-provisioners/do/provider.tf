
# this provider block is used to  generate a digital ocean entry for the jenkins key
# once and globally for each cluster.. the module we use relies on this key be created in Digital Ocean

provider "digitalocean" {
  token = "${var.do_token}"
} 

resource "digitalocean_ssh_key" "default" {
  name       = "storageos ssh key"
  public_key = "${file(var.pub_key_path)}"
}

