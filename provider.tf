terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "1.22.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# DigitalOcean provider
provider "digitalocean" {
  token = var.do_token
}

# AWS provider
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Existing Rebrain SSH Key
data "digitalocean_ssh_key" "terraform" {
  name = "REBRAIN.SSH.PUB.KEY"
}
