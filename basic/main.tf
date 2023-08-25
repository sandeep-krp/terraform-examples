module "network" {
  source = "./network"
  unique_id = var.unique_id
  vpc_cidr = var.vpc_cidr
  subnet_private_1 = var.subnet_private_1
  subnet_private_2 = var.subnet_private_2
}

module "storage" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "${var.unique_id}-db"
  engine = "postgres"
  family = "postgres15"
  db_name = var.database_username
  username = var.database_username
  create_db_subnet_group = true
  subnet_ids             = module.network.subnet_ids
  instance_class = "db.t3.micro"
  allocated_storage = "5"
}

terraform {
  backend "s3" {

  }
}
