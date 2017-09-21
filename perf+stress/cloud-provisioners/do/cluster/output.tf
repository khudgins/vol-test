output "ip-addrs" {
   value = [ "${formatlist("%s", "${digitalocean_droplet.storageos-ubuntu.*.ipv4_address}")}" ]
}
