
variable "ubuntu-version" {
  description = "Ubuntu version for digital ocean tags"
}

resource "digitalocean_tag" "tag" {
  name = "stress-tests"
}

variable "job-number" {
  description = "a unique job number to identify the machine"
}

resource "digitalocean_droplet" "stress-machine" {
  name = "${format("stress-%s", var.job-number)}"
  region = "lon1"
  size = "2gb"
  image = "${var.ubuntu-version}"

  connection {
    user = "root"
    type = "ssh"
    key_file = "${var.pvt_key}"
    timeout = "2m"
  }
}

