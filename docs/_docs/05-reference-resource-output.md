---
title:  "First terraform code"
permalink: /docs/reference-resource-outputs/
excerpt: "How to reference resource outputs in terraform"
last_modified_at: 2023-02-19T08:48:05-04:00
toc: true
---

In the [previous](/docs/first-terraform-code) steps we created a fresh VPC on AWS. If you think of the hierarchy of resources in AWS, you can think of VPC as a top level resource. Most of the further resources are created within this VPC. So when creating a resource lower in the hierarchy, we will need to reference the `id` of the existing VPC. Terraform has a very smart way to do this in which you don't have to store it yourself. The terraform will find this `id` on the go and will pass it next resource (lower in the hierarchy). Let's understand this using an example.

## Define a Subnet
Let's say we need to create one subnet within the VPC we created in the previous step. To do this, we add the following code to `main.tf` file:
```terraform
resource "aws_subnet" "tf_subnet" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name     = "My Subnet"
    Anything = "Everything"
  }
}
```
In the above code, we are defining a resource of type `aws_subnet` with a name `tf_subnet` which has three different attributes
- **vpc_id:** If you look at the RHS, you will find the syntax to reference the `id` of the existing VPC. In this like we are asking terraform to find a resource of type `aws_vpc` (in the current context of resources within terraform) with the name `tf_vpc` and fetch the `id` attribute of the that resource and set it to the `vpc_id` attribute of the subnet declaration.
- **cidr_block:** Here we simply declare the desired CIDR for the subnet
- **tags:** In the `tags` attribute we provide a set of key-value pairs for the desired subnet. These are tags that will be added to the subnet resource on AWS. You can add as many tags as you like.

**Note:** All the references like `aws_vpc.tf_vpc.id` are within the context of terraform. With this, you cannot reference an existing VPC in your account that was not created using this terraform code. In fact, the name `tf_vpc` name of the subnet is only valid within the terraform code. The name that appears on AWS will be decided by other attributes like `tags`.
{: .notice--info}

## Terraform apply to create Subnet
If you have done the changes correctly, now your code should look like [this].
If it does, you are ready to *apply* the changes.
```shell
terraform apply
```
Enter `yes` when asked for prompt, and after a few seconds your resource can be found in AWS. You can even verify this using your terminal(optional):
```shell
aws ec2 describe-subnets  --filters "Name=tag:Name,Values=My Subnet"
```

## What all can you reference
If you think about the expression `aws_vpc.tf_vpc.id`, you should have a question about the possible values you can put after `aws_vpc.tf_vpc`.<?>. Or how did we know had to use `id` and not `vpc_id` or `identifier`, etc?. You find that out by looking at the official documentation of the provider. Or more specifically, the resource's document within the provider document. A simple google search of 
'aws_vpc terraform' will take you to the official document [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#attributes-reference). Every terraform resource generates a set of *outputs* that can be referenced by other resources. Look for the 'Attributes' section at the end of the document. As you can see, the `aws_vpc` resource generates `id`, which we need to pass on to the Subnet resource.\

## What attributes a resource supports
How did we know that we have pass `vpc_id`, `cidr_block`, and the `tags` attributes? The answer is the same. You get this from the [official documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet). If you were paying attention while reading the previous document about `aws_vpc`, you might have noticed the list of attributes it support.

## Terraform State file
Another important thing to note in the `aws_vpc.tf_vpc.id` expression is that terraform does not reach AWS APIs to find the `id` of the resource(VPC). It actually gets it from a file where it stored the id when it created the resource. It's call the 'state file' in terraform. If you see a file named `terraform.tfstate` in the same folder where you have `main.tf`, that's the file where the current 'state' of the resources in that folder (just main.tf in our case). It got created when you first ran the `terraform apply` command the first time while creating VPC. It created the resources and saved the 'outputs' (the attributes section in the docs we talked about) of the resources. That's where it found the `id` of the VPC when we used the expression `aws_vpc.tf_vpc.id` in Subnet. And we ran `terraform apply` after adding subnet, it added the outputs of the subnet resource too in the same file.

**Note:** If you are planning to save the terraform files on a SCM like `git`, do not save the `terraform.tfstate` file. It contains sensitive information which is ideal to have on SCM. We will look for more secure ways save it. For now, let it be there.
{: .notice--info}


## Summary
- Terraform provides a feature of generating outputs per resource
- The outputs are stored in a state file
- The resources can reference the outputs of other resources
