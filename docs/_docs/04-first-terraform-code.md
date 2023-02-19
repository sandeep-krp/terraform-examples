---
title:  "First terraform code"
permalink: /docs/first-terraform-code/
excerpt: "How to write a basic terraform code"
last_modified_at: 2023-02-18T08:48:05-04:00
toc: true
---

Assuming that you have already set up your environment, let's get started with writing our first terraform code.

## Create a main.tf file
In an empty folder, create a new file named main.tf. We will write all our code in this file for now. The name of the file actually does not matter but the extension does matter. Terraform actually reads all the files with `.tf` extension and treat them all the same. But for our readability, we create files with different name.\
Content in `main.tf`
```terraform
resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
}
```
First thing that you should notice is that the syntax does not resemble anything that already exists. Its a bit similar to JSON but if you look closely, it is not really.
What this code essentially defines is, a resource of `aws_vpc` type with the name `tf_vpc` and the resource should have the property `cidr_block = "10.0.0.0/16"`. Here the word 'defines' is really of prime significance. You see, terraform syntax is *declarative*. Which means you define a state what you want to have, and let terraform make sure that the state of your target is what you have defined. We are *not* asking it to create a VPC. We are merely defining it and letting terraform do its magic to create and manage it.\
So we have declared a new VPC, but how do we ask terraform to read this file and perform the required action? 
## Executing terraform
To get started, let's execute the code with two simple steps. We will learn the more sophisticated ways in the later stages of this guide.
### Initialize with `terraform init`
Before we ask terraform to start executing the code, the terraform needs to download the stuff it needs to execute your code. Terraform only comes with a core component that reads the code user writes and passes it to something that can actually manage the users code. You can think of this as a plugin model where terraform is just managing lifecycle of the resources (in your code) which is deciding when to create, when to update and when to delete a resources, but how it will be created/updated/deleted is left to the plugin. This plugin in terraform language is called a *provider*. So in order to create resources on AWS, terraform needs to download the AWS *provider*. And how does it know what provider it should download? Well, it does not. You have tell it what provider your code needs. So we first need to update our `main.tf` file to add the provider.\
Add content in `main.tf`:
```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```
The code tells terraform that it needs a 'hashicorp/aws' provider with a version > 4.0, and it will be named as `aws` within this codebase. As you could imagine, our code can define multiple providers(within the same `terraform` block). Later on we will explore what could be the scenarios when we would need to do that.



Finally the content in `main.tf` should look like this:
```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
}
```
**Note:** The position of the `terraform` block in the above code does not matter. In fact, it does not matter for any of the blocks you are going to create. Terraform just treats them as a set of blocks, and the sequence does not matter.
{: .notice--info}

Within the folder where you created the `main.tf` file, run this following command
```shell
terraform init
```
With this command, terraform will look for any providers it needs to download. In our case, it will download the `hashicorp/aws` provider and make your system ready to execute your code. Yes, the resource creation does not take place with the `init` command. If you see a message that says `Terraform has been successfully initialized!`, you are good to go the next step. Now we will actually create the resource.

### Create resource with `terraform apply`
The below command will instruct terraform to make sure the state that you have declared for your resources is actually present on AWS as well. In other words, go and create the resources in `main.tf`.
```shell
terraform apply
```
You should see a output with prompt at the end like:
```terraform
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```
Take a moment and read what what the prompt says. It basically shows you the actions terraform is going to take. In terraform's language, this called a *plan*. The green `+` signs represents things that are going to be created fresh. Later on we will encounter a few other sings and colors too. For now, go ahead and enter `yes`.
If you see a message like this:
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
Congratulations, on creating your first resource using terraform.

## Conclusion
We define terraform resources that we want to create in `.tf` along with the terraform providers that can manage those resources. Then we have initialize the terraform so that it download the providers mentioned. Finally we run the `apply` command to actually create the resource.
