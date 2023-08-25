resource "aws_vpc" "tf_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = var.subnet_private_1
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.unique_id}-private-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = var.subnet_private_2
  availability_zone = "us-east-1b"
  tags = {
    Name = "${var.unique_id}-private-2"
  }
}

