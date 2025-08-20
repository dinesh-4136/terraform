# Create / import keypair
resource "tls_private_key" "this" {
  count     = var.generate_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  count           = var.generate_keypair ? 1 : 0
  content         = tls_private_key.this[0].private_key_pem
  filename        = var.private_key_path
  file_permission = "0600"
}

resource "aws_key_pair" "this" {
  key_name   = var.keypair_name
  public_key = var.generate_keypair ? tls_private_key.this[0].public_key_openssh : file("${var.private_key_path}.pub")
}

# Networking Components
# Pick 2 AZs to keep it simple (public in az[0], private in az[1])
data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = { Name = "${var.project}-private" }
}

# EIP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project}-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.allocation_id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "${var.project}-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

# Route table: public (0.0.0.0/0 -> IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project}-public-rt" }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route table: private (0.0.0.0/0 -> NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project}-private-rt" }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group (SSH + HTTP)
resource "aws_security_group" "web_ssh" {
  name        = "${var.project}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.allow_ssh_cidr]
    ipv6_cidr_blocks = []
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.allow_http_cidr]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.project}-sg" }
}

# EC2 instance + root volume
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_ssh.id]
  key_name               = aws_key_pair.this.key_name
  # iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Root volume selection
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  # Simple user data (optional)
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl enable httpd
              echo "<h1>Hello from ${var.project}</h1>" > /var/www/html/index.html
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.project}-ec2"
  }

  depends_on = [aws_route_table_association.public_assoc]
}

# Attach Elastic IP directly to the instance
resource "aws_eip" "instance" {
  domain = "vpc"
  tags   = { Name = "${var.project}-instance-eip" }
}

resource "aws_eip_association" "instance_assoc" {
  allocation_id = aws_eip.instance.id
  instance_id   = aws_instance.web.id
}

# Extra data EBS volume attach
resource "aws_ebs_volume" "data" {
  count             = var.data_volume_enabled ? 1 : 0
  availability_zone = aws_subnet.public.availability_zone
  size              = var.data_volume_size
  type              = var.data_volume_type
  encrypted         = true
  tags              = { Name = "${var.project}-data" }
}

resource "aws_volume_attachment" "data_attach" {
  count        = var.data_volume_enabled ? 1 : 0
  device_name  = "/dev/xvdb"
  volume_id    = aws_ebs_volume.data[0].id
  instance_id  = aws_instance.web.id
  skip_destroy = false
}
