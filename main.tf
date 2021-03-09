# Create a new SSH key using existing SSH key from local machine
resource "digitalocean_ssh_key" "info_at_nightsochi_ru_key" {
  name       = "Key for info_at_nightsochi_ru access"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Define data source to get existing SSH key
# Key name is known beforehand
data "digitalocean_ssh_key" "rebrain" {
  name = "REBRAIN.SSH.PUB.KEY"
}

# Create a web server in Frankfurt region
resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "TF-04-server"
  region = "fra1"
  size   = "s-1vcpu-2gb"
  tags   = ["devops", "info_at_nightsochi_ru"]
  ssh_keys = [data.digitalocean_ssh_key.rebrain.id, digitalocean_ssh_key.info_at_nightsochi_ru_key.fingerprint]
}

# Place IPv4 adress of the created droplet in the variable
locals {
  do_ipv4 = digitalocean_droplet.web.ipv4_address
}

# Define data source to get existing Route53 zone_id
# Zone is known beforehand (devops.rebrain.srwx.net)
data "aws_route53_zone" "rebrain" {
  name = "devops.rebrain.srwx.net"
}

# Create DNS record
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.rebrain.zone_id # zone id form data source
  name    = "ybelonozhkin.devops.rebrain.srwx.net"
  type    = "A"
  ttl     = "300"
  records = [local.do_ipv4]
}
