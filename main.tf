provider "aws" {
  region = "eu-west-1" # Empty region will use eu-central-1 as default
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "cm-api-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway  = true

  tags = {
    Environment = "dev"
    Name = "cm-api-vpc"
  }
}

module "jumpbox" {
    source = "./modules/jumpbox"

    env_prefix = var.env_prefix
    vpc_id = module.vpc.vpc_id
    my_ip = var.my_ip
    ec2_key_name = var.ec2_key_name
    instance_type = var.instance_type
    availability_zone = var.availability_zone
    subnet_id = module.vpc.public_subnets[0]
}

module "rds" {
    source = "./modules/rds"

    vpc_id = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    vpc_private_subnets = module.vpc.private_subnets
    env_prefix = var.env_prefix
    jumpbox_sg_id = module.jumpbox.jumpbox-sg.id
    db_name = var.db_name
    db_secret_id = var.db_secret_id
}






