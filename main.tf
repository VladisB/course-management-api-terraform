provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = "10.0.0.0/16"
  azs  = ["${var.aws_region}a", "${var.aws_region}b"]

  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_names = ["cm-api-vpc-private-subnet-1", "cm-api-vpc-private-subnet-2"]

  public_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnet_names = ["cm-api-vpc-public-subnet-1", "cm-api-vpc-public-subnet-2"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
  }

  vpc_tags = {
    Name = "cm-api-vpc"
  }

  private_route_table_tags = {
    Environment = "dev"
    Name        = "cm-api-vpc-private-rt"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = module.vpc.private_route_table_ids
}

module "jumpbox" {
  source = "./modules/jumpbox"

  env_prefix        = var.stage
  vpc_id            = module.vpc.vpc_id
  my_ip             = var.my_ip
  ec2_key_name      = var.ec2_key_name
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  subnet_id         = module.vpc.public_subnets[0]
}

module "rds" {
  source = "./modules/rds"

  vpc_id              = module.vpc.vpc_id
  vpc_cidr_block      = module.vpc.vpc_cidr_block
  vpc_private_subnets = module.vpc.private_subnets
  env_prefix          = var.stage
  db_name             = var.db_name
  db_secret_id        = var.db_secret_id

  jumpbox_sg_id        = module.jumpbox.jumpbox-sg.id
  codebuild_test_sg_id = module.codepipeline.codebuild_test_security_group_id
}

module "codepipeline" {
  source = "./modules/codepipeline"

  env_prefix                     = var.stage
  stage                          = var.stage
  vpc_id                         = module.vpc.vpc_id
  private_subnets                = module.vpc.private_subnets
  public_subnets                 = module.vpc.public_subnets
  aws_region                     = var.aws_region
  db_secret_id                   = var.db_secret_id
  api_app_cluster_name           = "cm-api-cluster-${var.stage}"      //cm-api-cluster-prod
  target_group_name              = "cm-api-target-group-${var.stage}" //cm-api-target-group-prod
  application_load_balancer_name = "cm-api-alb-${var.stage}"          //cm-api-alb-prod
}






