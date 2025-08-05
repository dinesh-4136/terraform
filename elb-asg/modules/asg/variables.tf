variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnets" {
  type = list(string)
}
variable "ec2_sg_id" {}
variable "target_group_arn" {}
