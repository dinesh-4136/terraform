provider "aws" {
  region = var.region
}

module "networking" {
  source     = "./modules/networking"
  vpc_cidr   = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.networking.vpc_id
  subnets        = module.networking.public_subnets
  alb_sg_id      = module.security.alb_sg_id
  target_port    = 80
}

module "asg" {
  source            = "./modules/asg"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnets           = module.networking.public_subnets
  ec2_sg_id         = module.security.ec2_sg_id
  target_group_arn  = module.alb.target_group_arn
}
