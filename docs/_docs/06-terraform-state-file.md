---
title:  "Terraform state file"
permalink: /docs/terraform-state-file/
excerpt: "What is terraform state file"
last_modified_at: 2023-03-11T08:48:05-04:00
toc: true
---

When you start working with terraform, you will notice that a file named `terraform.tfstate` is generated in the folder where you have the terraform code. This is a normal text file so you can easily open this up in a text editor. If you do, then you will see exactly what the name suggests. It represents the _state_ of the terraform code.

## Why does terraform needs a state file
There are two main reasons for having a state file
- Whenever you are running terraform code, terraform has to figure out which resources are newly added, which resource was already there but has changed a bit, or which resources have been completely removed. To do that, it needs to compare it with something
- Most of the resources generate output after they are created. These outputs are used in the next steps. For example, when a new VPC is created, the vpc-id is generated. It is stored in the state file so that it can be used for creating a resource that references the id (with `aws_vpc.tf_vpc.id` in a subnet).

## Working with the state file
- You should never try to change this file manually. Terraform will update it whenever it has to. You should never manipulate it in your text editor
- Never commit the state file in your source code. As you can image, this can contain secret values which you would not like to be committed to your SCM tool (github,SVN, etc.). 
The next obvious questions is, will your colleagues be able to work on the code further if they do not have the state file in their local? Since the state file won't be there, terraform will assume that the code has not been applied yet, and it has to create everything fresh. And when it tries to do that, it will see that a resource has already been created with the same and it will fail to create a new one. So, if not SCM, how do we share the terraform file with our team mates? Let's address that next.

## Terraform backend
Terraform backend is a code snippet you create that represents where to store this state file so that multiple people can access it. By default, terraform uses a backend called `local` that stores the file locally on the disk. But there are other backends it supports like S3, azurerm, kubernetes, http, etc. We will configure S3 backend in this series because we are anyway working with AWS resources and we have access to S3.

### Configuring s3 backend
For this step, you will need an existing S3 bucket. If you are thinking why do we need existing bucket when we create the bucket using the terraform code, then you are on the right track. The thing is, this is a chicken-and-egg problem. Who creates the infra that creates the infra? If you want to create the s3 bucket that stores the state file, where will state file stay for the code that creates this S3 bucket?Instead of trying to find a solution to this problem, better to create a S3 bucket manually. Remember, the goal of infra as code is not automated as much as we can. 100% automation is an unrealistic goal that will only consume your precious time that you could put in automating something else. Once the bucket is there, all we need to do is create the following snippet in the existing `main.tf` file:
```terraform
terraform {
  backend "s3" {
    bucket = "shyer-lexical-infra"
    key    = "tf-states/terraform-examples/basics"
    region = "us-east-1"
  }
}
```
**Note:** Don't forget the replace the bucket name which you created in `bucket` attribute.
{: .notice--info}

Now, if you try to run any terraform command, you will see an error saying `Backend initialization required, please run "terraform init"`. This is because terraform was using the `local` backend by default for your code up till now, but now it has detected that you have added a backend explicitly. Now it needs to take the local state file put it in s3 backend you specified. But it won't do it automatically. It will ask you to perform this step and you can do that with:
```shell
terraform init -migrate-state
```
With this, you are asking terraform to migrate the local state file to your fresh backend. It will ask for your confirmation, you just enter `yes` and your terraform state file will be copied to S3. Now you can safely delete the local `terraform.tfstate` file along with the `terraform.tfstate.backup` file. If you are wondering what is this new file, then its exactly what it says. It stores the backup of the last terraform state. Just in case if you want to refer to the previous state of the file once you are already hit the apply button.

## Conclusion
- State file stores the information about what resources it is currently controlling and what are their properties
- Never add the terraform state files to the source code
- Use a remote backend like S3 to store your terraform state file so that your terraform code can also be used by your team mates and not just you.