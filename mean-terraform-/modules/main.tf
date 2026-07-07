module "network" {
  source = "./modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr_a = var.public_subnet_cidr_a
  public_subnet_cidr_b = var.public_subnet_cidr_b
  private_subnet_cidr  = var.private_subnet_cidr
  aws_region           = var.aws_region     
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "app_instance" {
  source            = "./modules/app_instance"
  subnet_id         = module.network.public_subnets[0]
  security_group_id = module.security.app_sg_id
  instance_type     = var.instance_type_app
  ami_id            = var.app_ami_id
  key_pair_name     = var.key_pair_name
}

module "mongo_instance" {
  source            = "./modules/mongo_instance"
  subnet_id         = module.network.private_subnet_id
  security_group_id = module.security.mongo_sg_id
  instance_type     = var.instance_type_mongo
  ami_id            = var.mongo_ami_id
  key_pair_name     = var.key_pair_name
}

module "load_balancer" {
  source          = "./modules/load_balancer"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  alb_sg_id       = module.security.alb_sg_id
  app_instance_id = module.app_instance.instance_id
}
