data "aws_iam" "ubuntu" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = "ubuntu-anbox-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-anbox-server-20250312-f95ba830-8427-4876-9fc2-270678612806"
  }
}

data "aws_vpc" "my_vpc" {
  default = true
}

data "aws_security_group" "my_sg" {
  filter {
    name = "group-name"
    value = ["default"]
  }
}
