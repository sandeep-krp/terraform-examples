---
title:  "Terraform full environment stack"
permalink: /docs/terraform-full-stack/
excerpt: "How to create full environment stack using terraform"
last_modified_at: 2023-03-18T08:48:05-04:00
toc: true
---

In our current code, we just have two resources which a VPC and a subnet. In order to understand further concepts, we need a more real looking environment which can be actually used for something. So let's try to at least have a database deployed in a private subnet that can be then used in a application later on.

## Adding an RDS resource
To add the RDS resource, we need to find out what code will be needed. We will start with the same approach as did for VPC and Subnet. We search for the RDS resource within the AWS provider. Just by a simple google search of 'terraform aws rds', you will and [this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) link which tells us what code we need and what all options we need to pass to the RDS resource. We could just add the 'Basic' version of that code but that won't represent a real environment. In a real environment you would create multiple subnets -> create a subnet group out of that -> use that subnet group in your RDS, etc. After adding the required resources, the `main.tf` would look something like this:
```terraform
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
```
As you can see we have added availability zones to our subnets. The question of why we did that is not  related to learning terraform. This is something we need to understand early while learning terraform that the properties of the resources are governed by the target where these resource are created. If the target requires you to create a subnet group with more than one AZs involved, you will have to configure the same. It's not terraform which is telling you do so. It is the underlying AWS APIs that are used by the terraform provider which will make sure you are configuring it the way target needs. So when you see a terraform error, try to understand if this is coming from a target provider, or the terraform itself. One example when terraform itself will bark at you, is when you have syntax incorrect.

## Recap of resource references
Notice how in the `aws_security_group` resource, when we had to use the VPC CIDR, we did not copy pasted the CIDR sting. We referenced the 'output' of the VPC resource. This has multiple benefits:
- Tomorrow, if we have to change the CIDR, we don't need to replace it at multiple places
- It gives terraform the idea that the security group is actually dependent upon the VPC resource. So it first needs to create the VPC and then only it has to create the security group. You might think why is the terraform provider itself is not deciding the sequence of creation. Well, it will be too much of a work for the provider and it won't be 100% accurate as well. Only the user know which resources depend upon which other resource.

## Naming conventions
The resource names using which we refer resources within terraform do not require to have underscores as we have used. This is just by convention. You could name the subnet group as `subnet-group-1` and refer to it in `aws_db_instance` as `aws_db_subnet_group.subnet-group-1.id` and it will still work. But in the terraform world this has sort of become a convention to use `_` so that the code is consistent across teams and organizations.
These names are also used with the code so we need to name it in reference to just the terraform code and not in reference to actual infra. For example, the same terraform could/should be used to create multiple environments, so you don't want to put the environment name in the resource name. That way it becomes very specific to one environment which is not desirable.

## Conclusion
While this is still does not represent a true picture of a real environment that you would actually create, it is still good enough to get us going to learn different concepts or terraform. We do not want the environment to have crazy number of resource to become overwhelming and be an hinderance in our learning. Once you have the coming features of terraform under your control, you should be able to scale up this infrastructure at 10x of this one.
