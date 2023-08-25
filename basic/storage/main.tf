resource "aws_security_group" "allow_db" {
  name        = "${var.unique_id}-allow_db"
  description = "Allow DB access only within VPC"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = var.sg_allowed_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_this_vpc"
  }
}

resource "aws_db_instance" "tf_db" {
  allocated_storage    = 10
  db_name              = var.database_name
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  username             = var.database_username
  password             = var.database_password
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  
  db_subnet_group_name = aws_db_subnet_group.subnet_group_1.id
  vpc_security_group_ids = [ aws_security_group.allow_db.id ]
}

resource "aws_db_subnet_group" "subnet_group_1" {
  name       = "${var.unique_id}-main"
  subnet_ids = var.subnet_group_ids

  tags = {
    Name = "${var.unique_id}-subnet-group-1"
  }
}
