---
title:  "Terraform modules"
permalink: /docs/terraform-modules/
excerpt: "What are terraform modules and variables and why do we needed them"
last_modified_at: 2023-06-04T12:48:05-04:00
toc: true
---


In the [last step](/docs/terraform-full-stack/) we created a set of resources that can represent an 'environment' a team can work on. For example, it can represent a set of resources an application needs to run. The current set of resources are just a few networking infra and a RDS instance. Let's assume this is enough to run an application. If we consider the first environment as the development environment for the application, how do we create the testing environment for the app? One way is to copy-paste the same code, change some values like subnet names, rds name etc, and apply the changes to create another set of resources for the testing environment. But as you can imagine, this is not ideal. To solve this problem, we have terraform modules.


## How to create a terraform module
You don't have to do anything special to create a terraform module. Loosely speaking, any terraform code you write is a terraform module. Though it can be a really 'bad' module that cannot be reused as a module at all. For example, we hard-coded the VPC CIDR in the `main.tf`. If we need to reuse the same code in the testing environment (assuming the first deployment was for dev env), we need the CIDR to be somehow replaceable. That's the reason we have the 'terraform variables'.


### Terraform variables
Terraform allows us to define variables for our terraform modules. These variables are literally the stuff that varies per deployment of your module. In our example, these can be stuff like the VPC CIDR, the subnet CIDRs, the RDS password, etc. Things that do not need to change environment to environment, can be hardcoded in the module itself. e.g. the RDS parameter group name. You would not like to have postgres-13 in the development environment and postgres-14 in test.


#### Using terraform variables
If there is a parameter that you would like to be a variable, in the code you refer to it as `var.xyz` where `xyz` is the name of your variable. For example, we change our code as following to add variables:
```terraform
resource "aws_vpc" "tf_vpc" {
 cidr_block = var.vpc_cidr
}


resource "aws_subnet" "private_1" {
 vpc_id     = aws_vpc.tf_vpc.id
 cidr_block = var.subnet_private_1
 availability_zone = "us-east-1a"
 tags = {
   Name = "private-1"
 }
}


resource "aws_subnet" "private_2" {
 vpc_id     = aws_vpc.tf_vpc.id
 cidr_block = var.subnet_private_2
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


terraform {
 backend "s3" {
   bucket = "shyer-lexical-infra"
   key    = "tf-states/terraform-examples/basics"
   region = "us-east-1"
 }
}
```
Note the variables we added in format `var.<name-of-the-var>`: `vpc_cidr`, `subnet_private_1`, `subnet_private_2`, `database_name`,`database_username`, and `database_password`. Even though none of our variables are used more than once in our code, it is possible to do that. Because in this file we are not declaring the variables. We are using an already defined variable. Yes, we haven't done that up till now but we need to so that the variables can be actually used.


#### Declaring terraform variables
To define a variable in terraform we have to use the following syntax:
```
variable "database_username" {
 }
```
This tells terraform that the module will be using a variable named `database_username` and it can be used as many times as the module needs to. Though it can be added to the `main.tf` but to keep the code clean, terraform community keeps all the variables in different files they name the file as `variables.tf` (terraform allows you to use any file name). Following the same pattern, we can create the `variables.tf` file in the same folder as `main.tf` as following:
```terraform
variable "vpc_cidr" {
 }


variable "subnet_private_1" {
 }


variable "subnet_private_2" {
 }


variable "database_name" {
 }


variable "database_password" {
 }


variable "database_username" {
 }
```
Don't worry about the empty braces for now. There are certain fields you can add to each variable like `description` and `default`. We will add these as and when we require them. The bigger question as of now should be "how exactly do we pass the actual values to these variables?". Let's discuss that.


#### Passing variables to module
If you try to run the `terraform plan` on the current code, terraform will prompt you pass values to these variables:
```sh
terraform plan
var.database_name
 Enter a value:
```
Once you enter the values, it will prompt for the next variable and so not. As you can imagine, it is not possible for someone to keep putting different values manually. You will rarely use this feature.
The next option is to pass the variables with `-var`. e.g `terraform plan -var database_name=db1`. Even in this case the person who is running the command will have to pass the variables manually. But what if there is a small change that has to be done to the environment after a month and we have to run the same command. The person running the command needs to know exactly what was passed the first time we applied the module, otherwise the `terraform plan` might show changes that you don't anticipate. One solution to this is to have the command itself committed to the source control (like github) and nobody needs to remember anything. But this still looks like a hack and we have a better way to do it.
Terraform allows you to write a `tfvar` file that can be passed to the terraform command and pass all the variables the terraform module needs. If we assume that we are creating infra for our 'dev' environment, we can create a `dev.tfvars` file as follows:
```properties
vpc_cidr="10.0.0.0/16"
subnet_private_1="10.0.2.0/24"
subnet_private_2="10.0.3.0/24"
database_name="db1"
database_username="postgres"
database_password="foobarbaz"
```


Then you can run the terraform plan as `terraform plan -var-file=/path/to/dev.tfvars`. Terraform will replace all the `var.<name-of-the-var>` variables from the `tfvars` file and create the infrastructure for you. Now you can imagine that you can create another file `testing.tfvars` for your testing environment and using the same module can create another set of resources for testing. The placement of the `tfvars` files does not depend on the location of your terraform module. It does not have to be present in the same folder as the `main.tf` and `variables.tf`. In fact, it should not be because we want our module to be independent of any code that is environment specific. In the terraform module, we only want to keep the code that is common across all the deployments of your module.


This concludes the section of terraform variables. But we still have some elements left in the module to be fully reusable for creating new environments. Let's talk about that.


### Managing backends
When we talked about the [state files](/docs/terraform-state-file/), we learned that terraform stores the state-files in the 'backend' you provide. In our case we are defining the backend as below in the `main.tf` file:
```terraform
terraform {
 backend "s3" {
   bucket = "shyer-lexical-infra"
   key    = "tf-states/terraform-examples/basics"
   region = "us-east-1"
 }
}
```
When we run `terraform init`, it initializes the backend for you and prepares to store the terraform state file in S3. This state file represents the state of a set of resources created by your terraform module. If the same module is to be used to create another set of resources, then the state file will be different. So we need a different location on S3 for storing the state files for both dev and testing environments. With that said, I hope you are able to see the problem with our backend. Our backend does not have a variable that we can change for dev and testing to store the state file at different locations (either on the same S3 bucket or different). The reason we don't have a variable in the backend configuration is terraform does [not](https://github.com/hashicorp/terraform/issues/13022) allow that. There are a few ways to work around this but the best way I think is to create different `*.tfbackend` files for different environments and store along with the `tfvars` file. And while performing `terraform init`, we pass the path of the backend file using `-backend-config`.


#### Create dev.tfbackend
Let's say we have created the dev.tfvars file in `/env/dev/dev.tfvars`. We create a new file called `dev.tfbackend` in the same location `/env/dev/` and cut-paste the content within the 's3' backend block from the `main.tf`.
```terraform
bucket = "shyer-lexical-infra"
key    = "tf-states/terraform-examples/basics"
region = "us-east-1"
```
The `terraform` block in the `main.tf` now should like:
```terraform
terraform {
 backend "s3" {
  
 }
}
```


If we now run just `terraform init`, terraform will throw you an error like this:
```terraform
Initializing the backend...
╷
│ Error: Backend configuration changed
│
│ A change in the backend configuration has been detected, which may require migrating existing state.
│
│ If you wish to attempt automatic migration of the state, use "terraform init -migrate-state".
│ If you wish to store the current configuration with no changes to the state, use "terraform init -reconfigure".
```
This is because earlier when we executed `terraform init`, it had the backend snippet in the `main.tf` but now it does not. And we did not even try to pass the backend from the new location. But when we run terraform init with the `-backend-config` option, it should work:
```terraform
terraform init -backend-config=/env/dev/dev.tfbackend
```


**Note:** Changing the backend for your state file should be done really carefully. You risk losing the state in the process if you don't fully understand how the backend concept works and what different options are available while running `terraform init`. In most cases when you have already applied your changes and want to move the state file to a different location, you will have to use the `-migrate-state` when running `init`.
{: .notice--warning}


After a successful `init`, you should be able to run `apply` too:
```terraform
terraform apply -var-file=/env/dev/dev.tfvars
```


While starting with the dev environment, I made a mistake while creating the backend for the dev environment. I did not add the name `dev` in the backend path. If I had created a path like `tf-states/terraform-examples/basics/dev`, I would have been able to create another path for testing as `tf-states/terraform-examples/basics/testing`. The code would have been really nice and clean in that case. Fortunately, terraform has a way to move the state file to a new location. All we have to do is change the path in `dev.tfbackend` and run `init` with `-migrate-state`:
**dev.tfbackend:**
```properties
bucket = "shyer-lexical-infra"
key    = "tf-states/terraform-examples/basics/dev"
region = "us-east-1"
```
Run init:
```sh
terraform init -migrate-state -backend-config=/env/dev/def.tfbackend
```
Once this has run successfully, you can normally run `terraform init  -backend-config=/env/dev/def.tfbackend` without `-migrate-state`. The state-file is successfully moved and now we can happily create the new backend for the testing environment at `tf-states/terraform-examples/basics/testing`


### Creating new env with existing module
So we have created a module that can potentially create different environments like dev, testing, state etc. Let's try to create a testing environment too to test if our module is really useful.


#### Reusing module
Create a new folder as /env/testing/ along with `testing.tfvars` and `testing.tfbackend` files:
**testing.tfvars:**
```properties
vpc_cidr="10.1.0.0/16"
subnet_private_1="10.1.2.0/24"
subnet_private_2="10.1.3.0/24"
database_name="db2"
database_username="postgres"
database_password="foobarbazzzz"
```
Compare this to the existing `dev.tfvars` file and notice the changes.


**testing.tfbackend:**
```properties
bucket = "shyer-lexical-infra"
key    = "tf-states/terraform-examples/basics/testing"
region = "us-east-1"
```


To start working with the new environment, we will have to run the `init` again. This time we will pass the new backend:
```terraform
terraform init -backend-config=/env/testing/testing.tfbackend
```
When you run this from the same folder you have been running everything up till now, you will see the terraform will complain something like this:
```terraform
Initializing the backend...
╷
│ Error: Backend configuration changed
│
│ A change in the backend configuration has been detected, which may require migrating existing state.
│
│ If you wish to attempt automatic migration of the state, use "terraform init -migrate-state".
│ If you wish to store the current configuration with no changes to the state, use "terraform init -reconfigure".
```


If you read the error message carefully, you might be able to guess which option you should choose from what terraform is suggesting to you. Yes, this time we don't want to migrate the state. We want to `reconfigure` the local terraform settings so that the backend can point to the 'testing' backend and not the 'dev' one.
```terraform
terraform init -reconfigure -backend-config=/env/testing/testing.tfbackend
```


Now you should be able to run `plan` as well:
```terraform
terraform plan -var-file=/env/testing/testing.tfvars
```
You should be able to see the plan where terraform is telling you that it will create the listed 6 resources. But we have a problem in our code that will not allow us to run `apply`. We haven't parameterized the names of the resources in the module which will cause terraform `apply` to fail since it will not be able to create two resources with the same name. i.e. since the database subnet group is the name `main` is already created (while deploying the dev environment), AWS will not allow you to create another subnet group with the same name. The obvious solution to that would be to take the subnet group name as a variable in the module and pass it from the `dev.tfvars` and `testing.tfvars` files. The problem with this solution is that you would be asking for too many variables from the user who is deploying the terraform module. Note that the intent of the module is to write once and use multiple times. So other folks in your team should also be able to use the module you are writing. The next best thing to do is to take a single parameter that uniquely defines one instance of your module and prefix that to all the resources you are creating.


#### Creating unique resource names
Our module can take a variable named `env_name` or `resource_prefix` or `unique_id` or anything that uniquely defines a single deployment of your module. For example, if the primary objective of the module is to create an RDS instance, we use the existing variable `database_name` to prefix the names of all the other resources. For example, the subnet group name could be `name = "${var.database_name}-main"`. But we might decide to change the scope of the module in future and add more resources. So it is better to accept a new variable called `unique_id`. Here are changes we need to do:
We add a new variable to the `variables.tf` file.
**variables.tf:**
```terraform
variable "unique_id" {
 }


variable "vpc_cidr" {
 }


variable "subnet_private_1" {
 }


variable "subnet_private_2" {
 }


variable "database_name" {
 }


variable "database_password" {
 }


variable "database_username" {
 }
```
In the `dev.tfvars` file we add the value for `unique_id` which we want to use for dev environment:
**dev.tfvars:**
```properties
unique_id="env-dev"
vpc_cidr="10.1.0.0/16"
subnet_private_1="10.1.2.0/24"
subnet_private_2="10.1.3.0/24"
database_name="db2"
database_username="postgres"
database_password="foobarbazzzz"
```
Doing the same for `testing.tfvars` too:
```properties
unique_id="env-testing"
vpc_cidr="10.1.0.0/16"
subnet_private_1="10.1.2.0/24"
subnet_private_2="10.1.3.0/24"
database_name="db2"
database_username="postgres"
database_password="foobarbazzzz"
```


In the `main.tf`, we change the resource names to be based on the `unique_id`. After making all the changes, the file would look like this:
**main.tf:**
```terraform
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


resource "aws_db_subnet_group" "subnet_group_1" {
 name       = "${var.unique_id}-main"
 subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]


 tags = {
   Name = "${var.unique_id}-subnet-group-1"
 }
}


resource "aws_security_group" "allow_db" {
 name        = "${var.unique_id}-allow_db"
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


terraform {
 backend "s3" {


 }
}


```


After making the above changes, let's re-create the dev environment first. You will see that since you have changed the name of the resources, terraform is 'planning' to re-create some of those resources. Let it do it, and apply the changes with `terraform apply`.
```terraform
terraform init -reconfigure -backend-config=/env/dev/dev.tfbackend
terraform plan -var-file=/env/dev/dev.tfvars
terraform apply -var-file=/env/dev/dev.tfvars
```


You should be able to create the testing environment too:
```terraform
terraform init -reconfigure -backend-config=/env/testing/testing.tfbackend
terraform plan -var-file=/env/testing/testing.tfvars
terraform apply -var-file=/env/testing/testing.tfvars
```


With the above technique, the RDS instances created by the two environments would be named as `db1` and `db2` since we have named them explicitly in our `tfvars` files. But if in `main.tf` instead of using `var.database_name` we had used `"${var.unique_id}-db"`, it would have been much cleaner in the code and easy to debug stuff on AWS console because all the resources of an environment would have the same prefix. Also, the user of the module would have to deal with one less variable. So it is up to the module developer to decide what's the best approach to name the resources within one environment, what should be hard-coded and what should be taken as input from the module user (in `tfvars` file).


## Conclusion
The Terraform module is probably the most important concept to understand. It helps you write code once to create a set of resources. And then allows re-create the same set of resources with different sets of parameters without writing any code (apart from the `tfvar` and `tfbackend` files).

