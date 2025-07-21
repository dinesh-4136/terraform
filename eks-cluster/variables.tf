variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "environment" {
  default = "dev"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  default = "demo-eks-cluster"
}

variable "admin_iam_user_arn" {
  description = "IAM user ARN for kubectl admin access"
  type        = string
}
