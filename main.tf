# Create a new SSH key using existing SSH key from local machine
resource "digitalocean_ssh_key" "info_at_nightsochi_ru_key" {
  name       = "Key for info_at_nightsochi_ru access"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Define data source to get existing SSH key
# SSH key name is known beforehand
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
  droplets = flatten([
    for login, prefixlist in var.devs : [
      for prefix in prefixlist : [
        "${login}-${prefix}"
      ]
    ]
  ])
  droplets_list = tolist(local.droplets[*]) # store result as list
  droplets_set  = toset(local.droplets[*]) # store result as set
}

# Define random password resource
resource "random_password" "droplet_password" {
  for_each = local.droplets_set
  length   = 10
  special  = true
}

# Create a web server in Frankfurt region
resource "digitalocean_droplet" "web" {
  for_each = local.droplets_set
  name     = each.key
  image    = "ubuntu-20-04-x64"
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
      "echo root:\"${random_password.droplet_password[each.key].result}\" | chpasswd"
    ]
  }
}

# Define data source to get existing Route53 zone_id
# Zone is known beforehand (devops.rebrain.srwx.net)
data "aws_route53_zone" "rebrain" {
  name = "devops.rebrain.srwx.net"
}

# Create DNS record
resource "aws_route53_record" "www" {
  for_each = digitalocean_droplet.web
  records  = [digitalocean_droplet.web[each.key].ipv4_address]
  zone_id  = data.aws_route53_zone.rebrain.zone_id
  name = digitalocean_droplet.web[each.key].name
  type = "A"
  ttl  = "300"
}

# Generate local file with credentials and IP
resource "local_file" "outputs" {
  content = templatefile("${path.module}/template.tpl", {
    names_list           = local.droplets_list # to iterate
    droplets_list        = digitalocean_droplet.web
    route53_records_list = aws_route53_record.www
    passwords            = random_password.droplet_password
  })
  filename = "${path.module}/outputs"

}
