resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = tls_private_key.mykey.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.mykey.private_key_pem
  filename = pathexpand("~/Downloads/mykey.pem")
}

resource "aws_instance" "myec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [data.aws_security_group.my_sg.id]
  tags = {
    Name = "myec2"
  }
}
