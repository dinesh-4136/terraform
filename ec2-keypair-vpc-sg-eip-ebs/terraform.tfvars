# Project settings
project = "my-demo"
region  = "ap-south-1"

# Networking CIDRs
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# EC2 config
instance_type   = "t3.small"
allow_ssh_cidr  = "0.0.0.0/0"
allow_http_cidr = "0.0.0.0/0"

# Root volume
root_volume_size = 50
root_volume_type = "gp3"

# Extra data volume (attached EBS)
data_volume_enabled = true
data_volume_size    = 40
data_volume_type    = "gp3"

# Key pair generation on-the-fly
generate_keypair = true
keypair_name     = "my-demo-key"
private_key_path = "./my-demo-key.pem"
