variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "instance_type" {
  default = "t2.micro"
}
