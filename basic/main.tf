resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "tf_subnet" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "My Subnet"
  }
}

terraform {
  backend "s3" {
    bucket = "shyer-lexical-infra"
    key    = "tf-states/terraform-examples/basics"
    region = "us-east-1"
  }
}
