---
title:  "Using open source modules"
permalink: /docs/using-open-source-modules/
excerpt: "How to use open source terraform modules"
last_modified_at: 2023-08-24T12:48:05-04:00
toc: true
---

In the last chapter we created two modules `network` and `storage` and called them with our outer `main.tf` file. Along with referencing to the local modules (`network` and `storage`), you can refer to modules which other have created and put on the internet. Terraform provides you can option to refer to those module via git.

### Why open source modules
When we created the storage module, we had to create a subnet group, a security group within that module. In future we might have to add other stuff too like parameter group, etc. So instead of us creating these set of resources within our module and managing the variables and outputs for the same, you can choose to use an open source module which does something similar. If it is meeting your requirements, it is always a better option rather than managing your own. Only when these modules don't create the resources the way you like them too, start creating your own module. 

### Replace storage module with OS module
The [terraform-aws-module](https://github.com/terraform-aws-modules) has a lot of read to use terraform modules. Let us try to replace our storage module with the [terraform-aws-rds](https://github.com/terraform-aws-modules/terraform-aws-rds) module. The [README](https://github.com/terraform-aws-modules/terraform-aws-rds#readme) on the module will tell you what all variables does it expect and what outputs it generates.

We will just have to replace the existing storage module with the above module. The final code in the outer `main.tf` will look like this:
```terraform
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
```

After making this change when you run `terraform plan`, you will see the resources created by the git module. And now since we are not referring to the local storage module, we can remove the `storage` folder.
```shell
rm -rf storage
```

### Locking the module version
The above code will use the latest version of the module by default. So if there is new code added to the open source module, you will see the change the next time you run `init -upgrade`. You would think this is a good thing but in production this could cause some unexpected behavior. It is better that we lock the module version so that your terraform code always references to a particular version of git module rather than always referring to the latest. You can do that just by adding the `version` variable along with the source. 
```terraform
module "storage" {
  source = "terraform-aws-modules/rds/aws"
  version = "6.1.0"
  .
  .
}
```


### Conclusion
When you are starting with terraform it is better to first get used to creating the resources without the github modules. This will give you experience of how the terraform modules are created. And that will give you a fair idea of how the open-source community is creating the modules.
