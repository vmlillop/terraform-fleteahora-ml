locals {
  tags = {
    Project = "FleteAhora"
    Managed = "Terraform"
  }
}

module "network" {
  source          = "./modules/network"
  create_network  = var.create_network
  vpc_id          = var.vpc_id
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = local.tags
}

module "rds" {
  source            = "./modules/rds"
  create_rds        = var.create_rds
  vpc_id            = module.network.vpc_id
  private_subnets   = module.network.private_subnet_ids
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  tags              = local.tags
}

module "backend" {
  source           = "./modules/backend"
  vpc_id           = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_ids[0]
  key_name         = var.key_name
  instance_type    = var.instance_type
  repo_url         = var.repo_url
  app_port         = var.app_port
  jwt_secret       = var.jwt_secret
  cors_origin      = var.cors_origin

  db_host = module.rds.endpoint_host
  db_user = var.db_username
  db_pass = var.db_password
  db_name = var.db_name

  rds_sg_id = module.rds.sg_id

  tags = local.tags
}
