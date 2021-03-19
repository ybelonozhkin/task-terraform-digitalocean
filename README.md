# Terraform final task

This module creates resources according to a variable describing 1. users, 2. their machines.

Passwords for root are generated at random.

After creation, all machines' FQDN, IP addresses, and passwords are stored in the output file.

## Installation

0. Install Terraform
1. Obtain Rebrain credentials: DigitalOcean key and AWS secret.
2. Generate local id_rsa key.

## Config

Configure devs.tf: write usernames and their machines. For example:

```
# Describe users and their machines
variable "devs" {
  type = map(any)
  default = {
    ybelonozhkin = ["app", "lb"],
    speter       = ["dbserver", "storage", "firewall-corp"]
  }
}
```

Here are two users, with 5 machines.

## Usage

```
terraform init
terraform apply
```

## Outputs
After finishing apply action file 'outputs' is created.


```
1: speter-dbserver.devops.rebrain.srwx.net 104.248.28.149 &@vZ0gSZGW
2: speter-storage.devops.rebrain.srwx.net 104.248.30.98 Q]AZPlOMe#
3: speter-firewall-corp.devops.rebrain.srwx.net 134.209.255.233 E1D_zU0@CU
4: ybelonozhkin-app.devops.rebrain.srwx.net 134.209.225.158 rYlq%zZq8C
5: ybelonozhkin-lb.devops.rebrain.srwx.net 104.248.133.27 {QPvH@KSQp

```

## Cresdits

[Yuriy Belonozhkin](https://www.linkedin.com/in/yuriy-belonozhkin/)
