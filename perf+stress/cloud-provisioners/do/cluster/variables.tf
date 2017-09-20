
variable "ubuntu_version" {
  description = "Ubuntu version for digital ocean tags"
}

variable "tag" {
  description = "tag on cluster instances"
}

variable "cluster_size" {
  description = "size of storageos cluster"
}

variable "machine_size" {
  description = "RAM size of digital ocean droplet in cap (eg. 2gb)"
}

variable "cli_version" {
  description = "Version of cli to download on each node"
}

variable "node_container_version" {
  description = "Version of the storageos/node container to run"
}

variable "region" {
  description = "digital ocean region for cluster"
}

variable "ssh_fingerprint" {
  description = "SSH fingerprint of key to add to digital ocean, must be already in account"
}

variable "do_token" {}
variable "pvt_key_path" {}


