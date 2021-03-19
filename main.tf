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

# Define list of all droplets to be created
# Output list contains all combintations of machine names 
# from devs.tf. List is like:
# 'loginA-prefixA1'
# 'loginA-prefixA2'
# 'loginB-prefixB1'
# 'loginB-prefixB2'
locals {
  droplets_list = toset(flatten([
    for login, prefixlist in var.devs : [
      for prefix in prefixlist : [
        "${login}-${prefix}"
      ]
    ]
  ]))
}

# Show created list in console for debug purposes
output "droplets_list_output" {
  value = local.droplets_list
}

# Helpful source:
# https://medium.com/swlh/terraform-iterating-through-a-map-of-lists-to-define-aws-roles-and-permissions-a6d434182114

# Define random password resource
resource "random_password" "droplet_password" {
  #  count   = var.droplet_count
  for_each = local.droplets_list
  length   = 10
  special  = true
}

# Create a web server in Frankfurt region
resource "digitalocean_droplet" "web" {
  #  count    = var.droplet_count
  for_each = local.droplets_list
  name     = each.key
  image    = "ubuntu-20-04-x64"
  #  name     = "TF-04-server-${count.index + 1}"
  region   = "fra1"
  size     = "s-1vcpu-2gb"
  tags     = ["devops", "info_at_nightsochi_ru"]
  ssh_keys = [data.digitalocean_ssh_key.rebrain.id, digitalocean_ssh_key.info_at_nightsochi_ru_key.fingerprint]
  provisioner "remote-exec" {
    connection {
      type  = "ssh"
      user  = "root"
      host  = tostring(self.ipv4_address)
      agent = true
    }
    inline = [
      # "useradd ${var.do_user}",
      "echo root:\"${random_password.droplet_password[each.key].result}\" | chpasswd"
    ]
  }
}

# Show generated password(s) for debug purposes
# output "droplet_password" {
#  value = random_password.droplet_password[*]
# }

# Define data source to get existing Route53 zone_id
# Zone is known beforehand (devops.rebrain.srwx.net)
data "aws_route53_zone" "rebrain" {
  name = "devops.rebrain.srwx.net"
}

# Create DNS record
resource "aws_route53_record" "www" {
  #  count   = var.droplet_count
  for_each = digitalocean_droplet.web
  records  = [digitalocean_droplet.web[each.key].ipv4_address]
  zone_id  = data.aws_route53_zone.rebrain.zone_id # zone id from data source
  #  name    = "ybelonozhkin-${count.index + 1}"
  name = digitalocean_droplet.web[each.key].name
  type = "A"
  ttl  = "300"
}

# Generate output file with credentials and IPs
# resource "local_file" "outputs" {
#  filename = "${path.module}/output"
#  content  = templatefile("${path.module}/template.tpl", { port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })
#}

