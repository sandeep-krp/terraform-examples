resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-2"
  }
}

resource "aws_db_subnet_group" "subnet_group_1" {
  name       = "main"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "subnet-group-1"
  }
}

resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow DB access only within VPC"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.tf_vpc.cidr_block]
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
  db_name              = "db1"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  
  db_subnet_group_name = aws_db_subnet_group.subnet_group_1.id
  vpc_security_group_ids = [ aws_security_group.allow_db.id ]
}

terraform {
  backend "s3" {
    bucket = "shyer-lexical-infra"
    key    = "tf-states/terraform-examples/basics"
    region = "us-east-1"
  }
}
