module "network" {
  source = "./network"
  unique_id = var.unique_id
  vpc_cidr = var.vpc_cidr
  subnet_private_1 = var.subnet_private_1
  subnet_private_2 = var.subnet_private_2
}

module "storage" {
  count = var.storage_enabled ? 1 : 0
  source = "./storage"
  unique_id = var.unique_id
  database_name = var.database_name
  database_password = var.database_password
  database_username = var.database_username
  vpc_id = module.network.vpc_id
  sg_allowed_cidr = [var.vpc_cidr]
  subnet_group_ids = module.network.subnet_ids
}

terraform {
  backend "s3" {

  }
}
