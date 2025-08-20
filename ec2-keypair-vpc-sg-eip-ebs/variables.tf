# Project settings
variable "project" {
  type        = string
  description = "Project name (used for tagging and resource naming)"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
}

# Networking CIDRs
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

# EC2 config
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "allow_ssh_cidr" {
  type        = string
  description = "CIDR block allowed for SSH access"
}

variable "allow_http_cidr" {
  type        = string
  description = "CIDR block allowed for HTTP access"
}

# Root volume
variable "root_volume_size" {
  type        = number
  description = "Size of the root EBS volume (GiB)"
}

variable "root_volume_type" {
  type        = string
  description = "Type of the root EBS volume (gp2, gp3, io1, etc.)"
}

# Extra data volume (attached EBS)
variable "data_volume_enabled" {
  type        = bool
  description = "Whether to attach an additional EBS data volume"
}

variable "data_volume_size" {
  type        = number
  description = "Size of the additional data EBS volume (GiB)"
}

variable "data_volume_type" {
  type        = string
  description = "Type of the additional data EBS volume"
}

# Key pair generation
variable "generate_keypair" {
  type        = bool
  description = "Whether to generate a new key pair on the fly"
}

variable "keypair_name" {
  type        = string
  description = "Name of the EC2 key pair"
}

variable "private_key_path" {
  type        = string
  description = "Local path where the generated private key should be stored"
}
