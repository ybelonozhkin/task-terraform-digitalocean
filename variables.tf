variable "do_token" {
  type        = string
  description = "Digital Ocean from the Resource section of the task list"
}
variable "pvt_key" {
  type        = string
  description = "Local path to private key to place on new host"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "droplet_count" {
  type        = number
  description = "DO droplet count"
  default     = 3
}
