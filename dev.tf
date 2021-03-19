# Describe users and their machines
variable "devs" {
  type = map(any)
  default = {
    ybelonozhkin = ["app", "lb"],
    speter       = ["dbserver", "storage", "firewall-corp"]
  }
}
