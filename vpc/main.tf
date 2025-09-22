provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-public-subnet"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "my-private-subnet"
  }
}

resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-internet-gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_route" {
  subnet_id      = aws_subnet.public_subnets.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets.id
  tags = {
    name = "nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_route" {
  subnet_id      = aws_subnet.private_subnets.id
  route_table_id = aws_route_table.private_rt.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_is" {
  value = aws_subnet.public_subnets.id
}
output "private_subnet_id" {
  value = aws_subnet.private_subnets.id
}
output "internet_gateway" {
  value = aws_internet_gateway.my_ig.id
}
output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}
output "public_route_table_association_id" {
  value = aws_route_table_association.public_route.id
}
output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}
output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}
output "private_route_table_association_id" {
  value = aws_route_table_association.private_route.id
}
output "nat-eip" {
  value = aws_eip.nat_eip.id
}
