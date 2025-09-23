data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250821"]
  }
}

data "aws_vpc" "my_vpc" {
  default = true
}

data "aws_security_group" "my_sg" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}
