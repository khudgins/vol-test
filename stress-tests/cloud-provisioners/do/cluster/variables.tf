
variable "ubuntu-version" {
  description = "Ubuntu version for digital ocean tags"
}

variable "tag" {
  description = "Optional tag on cluster instances"
}

variable "cluster_size" {
  description = "size of storageos cluster"
}

variable "cluster_id" {
  description = "storageos cluster id"
}

variable "region" {
  description = "digital ocean region for cluster"
}

variable "do_token" {}
variable "pub_key" {}
variable "pvt_key_path" {}


