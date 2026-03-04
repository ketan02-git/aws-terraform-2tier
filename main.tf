module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnets
  alb_sg            = module.security.alb_sg
}

module "compute" {
  source            = "./modules/compute"
  private_subnets   = module.vpc.private_subnets
  ec2_sg            = module.security.ec2_sg
  target_group_arn  = module.alb.target_group_arn
  instance_type     = var.instance_type
}