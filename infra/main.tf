provider "aws" {
  region = var.region
}

module "network" {
  source = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  project_name        = var.project_name
}

module "mongodb" {
  source = "./modules/mongodb"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.private_subnet_id
  app_sg_id     = module.app_server.security_group_id
  instance_type = var.instance_type
  key_name      = var.key_name
  project_name  = var.project_name
}

module "app_server" {
  source = "./modules/app_server"

  vpc_id             = module.network.vpc_id
  public_subnet_id   = module.network.public_subnet_id
  mongodb_private_ip = module.mongodb.private_ip
  instance_type      = var.instance_type
  key_name           = var.key_name
  project_name       = var.project_name
  alb_sg_id          = module.load_balancer.alb_sg_id
}

module "load_balancer" {
  source = "./modules/load_balancer"

  vpc_id             = module.network.vpc_id
  public_subnet_id   = module.network.public_subnet_id
  public_subnet_id_2 = module.network.public_subnet_id_2
  app_server_id      = module.app_server.instance_id
  project_name       = var.project_name
}