---
title:  "Terraform plan"
permalink: /docs/terraform-plan/
excerpt: "What is terraform plan"
last_modified_at: 2023-03-12T08:48:05-04:00
toc: true
---

Moving further with our simple examples from the previous steps, let's image that after creating the subnet you realized that the CIDR you chose for the subnet was already used in your network. Now how do you change your code so that the existing subnet is changed with the new CIDR. Here is the existing code for you reference:
```terraform
resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "tf_subnet" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"

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
```
The obvious thing to change in the code would be the CIDR of the subnet itself. i.e. change `cidr_block = "10.0.1.0/24"` to `cidr_block = "10.0.2.0/24"`. If we make this change and run the code, do you think the existing subnet would change or the existing subnet will be deleted and created afresh? This would depend upon AWS. If AWS support changing the CIDR of a subnet, chances are terraform would also allow it, but it is not supported by AWS, then terraform 'will' have to destroy the existing subnet and create a new one. But how do you know this without actually running the code (`terraform apply`)? Exactly for this reason, terraform provides the feature of `plan`.

## Terraform plan
To simply put, terraform plan is a representation of what terraform is going to do when you run `terraform apply` looking at the changes you have made to the code. No actual changes are done to the target when a `plan` command is run. You can look at this plan and decide if you want to make any further changes or the changes terraform is showing is looking good to you are you are good to apply those changes. In the example above, when we change `cidr_block = "10.0.1.0/24"` to `cidr_block = "10.0.2.0/24"` and run `terraform plan`, here is what you see:
```
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_subnet.tf_subnet must be replaced
-/+ resource "aws_subnet" "tf_subnet" {
      ~ arn                                            = "arn:aws:ec2:us-east-1:123456789012:subnet/subnet-0129e85b03ffec067" -> (known after apply)
      ~ availability_zone                              = "us-east-1f" -> (known after apply)
      ~ availability_zone_id                           = "use1-az5" -> (known after apply)
      ~ cidr_block                                     = "10.0.1.0/24" -> "10.0.2.0/24" # forces replacement
      ~ id                                             = "subnet-0129e85b03ffec067" -> (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      - map_customer_owned_ip_on_launch                = false -> null
      ~ owner_id                                       = "123456789012" -> (known after apply)
      ~ private_dns_hostname_type_on_launch            = "ip-name" -> (known after apply)
        tags                                           = {
            "Name" = "My Subnet"
        }
        # (8 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

If we read the output carefully, terraform shows you exactly what it is going to do. The `+` sign represents adding of a new field and the `-` sign shows removal of an attribute. The `~` sign represents that the attribute will be changed without getting removed and added again. The line `# aws_subnet.tf_subnet must be replaced` is really important. It means terraform is going to first delete the existing `aws_subnet.tf_subnet` resource present in our code and then is going to add again. It also shows what is causing this replacement. Check the line `~ cidr_block = "10.0.1.0/24" -> "10.0.2.0/24" # forces replacement`. Another important line to note here is the summary at the last. `Plan: 1 to add, 0 to change, 1 to destroy.`. There will be times when you will see a very big plan which you will not be able to read very quickly. But you can always look at the last line to see how many resources are getting added, destroy and updated.

When you are comfortable with the plan, you can run a `terraform apply` to actually apply the changes shown in the plan. Let's try to do that.
```shell
terraform apply
```
When you run `terraform apply`, you will see the plan again. Terraform makes sure you are seeing the plan of what it is going to do before it actually does it. You can very the plan one more time and accept and approve the changes by entering `yes`.
This might bring up a question in your mind that if the plan is shown while running the `apply` command, why do we even need the `plan` command? The `terraform plan` command allows you to store the 'plan' as a file which can be then applied using `terraform apply`. This makes sure that the terraform will do exactly what it is shown in the plan. Is it possible that with same code, the output of the `terraform plan` command is different if ran at different times? Yes, it is. Consider this scenario: You have a piece of terraform code -> you make a change in the code -> See the terraform plan -> Wait for 5 mins-> Within these 5 minutes, somebody goes and makes some changes to the same resource on the target (AWS in our case) -> You run the `terraform apply`. You will see that the plan has changed since the last time you checked. This is why, sometimes it is important that you store the plan as a file, and then use the same plan to execute whenever you are ready.
You can store the plan as a file by running `terraform plan -out main.plan`. This will create a plan file in the current working directory. You can view the same plan whenever you like to by running `terraform show main.plan`.

**Note:** The name of the file is not important here. You can choose the name of your liking. Also, the plan file not a normal text file. You will not be able to open it in a text editor. You need to view this using `terraform show main.plan`.
{: .notice--info}
When you have the plan as a file, you can run `terraform apply main.plan` to apply the changes present in the plan. This is how you make use of the `terraform plan` command. It really helps in making sure you know what changes you are doing on the target.

## Conclusion
- The `terraform plan` shows the plan of action for changes in your code
- The plan can be stored as a file
- The plan file can be applied whenever needed. Terraform will only do what is there in the plan
- It helps you know exactly what changes you are applying on the target