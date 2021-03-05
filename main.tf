# Create a new SSH key
resource "digitalocean_ssh_key" "info_at_nightsochi_ru_key" {
  name       = "Key for info_at_nightsochi_ru access"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Calculate fingerprint from existing Rebrain public key
# TO-DO: put this calculation to variables.tf for clarity?
data "external" "rebrain_key_fingerprint" {
  program = ["bash", "calculate-fingerprint.sh"]
  }



# Create a web server in Frankfurt region
resource "digitalocean_droplet" "web" {
  image    = "ubuntu-20-04-x64"
  name     = "TF-04-server"
  region   = "fra1"
  size     = "s-1vcpu-2gb"
  tags     = ["devops", "info_at_nightsochi_ru"]
  ssh_keys = [data.external.rebrain_key_fingerprint.result.fingerprint, digitalocean_ssh_key.info_at_nightsochi_ru_key.fingerprint]
}
