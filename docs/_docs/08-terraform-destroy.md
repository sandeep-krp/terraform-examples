---
title:  "Terraform destroy"
permalink: /docs/terraform-destroy/
excerpt: "What is terraform destroy"
last_modified_at: 2023-03-18T08:48:05-04:00
toc: true
---

Terraform also allows you to delete the full stack of resources if you want to. With the `terraform destroy` command, you will be able to destroy all of the resources you created using the code in your working directory. To be more specific, it reads the backend -> finds the terraform state file, and tries to delete all the resources it has.

## Delete sequence
When we talked about referencing resources in terraform code, we learned that terraform knows the sequence of creation of resource using the references to the resources. For example, if the VPC id is used as a resource reference in the definition of the subnet resource, it knows that first it has to make sure the VPC is there, before it tries to create the subnet. The same linking is used while deleting the resources too. Only it starts deleting from the bottom of the tree for obvious reasons.

## Running terraform destroy
While you are in the directory where your `.tf` files are, you can run `terraform destroy` to destroy whatever resources terraform is managing.
```terraform
terraform destroy
```
This will even show you a plan that it is going to delete all the resources you are managing with terraform. If case you change your mind, enter 'no' to abort the process. If you are okay with destroying all resources, enter 'yes' and let terraform destroy the universe.
```terraform
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_subnet.tf_subnet will be destroyed
  - resource "aws_subnet" "tf_subnet" {
      - arn                                            = "arn:aws:ec2:us-east-1:1234567890123:subnet/subnet-0ee70b5a6b6486e3b" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1a" -> null
      - availability_zone_id                           = "use1-az2" -> null
      - cidr_block                                     = "10.0.2.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0ee70b5a6b6486e3b" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "1234567890123" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "My Subnet"
        } -> null
      - tags_all                                       = {
          - "Name" = "My Subnet"
        } -> null
      - vpc_id                                         = "vpc-0a18057428d4e2ad3" -> null
    }

  # aws_vpc.tf_vpc will be destroyed
  - resource "aws_vpc" "tf_vpc" {
      - arn                                  = "arn:aws:ec2:us-east-1:1234567890123:vpc/vpc-0a18057428d4e2ad3" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-093b94581bd877edb" -> null
      - default_route_table_id               = "rtb-0bfdc7166a3e154df" -> null
      - default_security_group_id            = "sg-0729a6050d83b7b11" -> null
      - dhcp_options_id                      = "dopt-037a781338f0d4d8f" -> null
      - enable_classiclink                   = false -> null
      - enable_classiclink_dns_support       = false -> null
      - enable_dns_hostnames                 = false -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0a18057428d4e2ad3" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0bfdc7166a3e154df" -> null
      - owner_id                             = "1234567890123" -> null
      - tags                                 = {} -> null
      - tags_all                             = {} -> null
    }

Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```
**Note:** It is important to note that terraform only destroy what is there in the state file. It does not matter what changes you make to the code before you run destroy. It will ignore that and just destroy what is there in the state file.
{: .notice--info}

## When do we need to destroy
One of the reasons why Infrastructure-as-code got so popular because it gives you ability to build once and repeat as many times as you like. But not every piece of infra-as-code is repeatable. We need to write in a certain way so that it is actually repeatable (we will learn these principle as we go along this series). To test if your code is repeatable or not, you can destroy the full stack of resources and create it again. It is functional back again, you can say your code is ready to be repeated at multiple places. That's where most people use the destroy command.
Another obvious use of the destroy feature is when you actually don't need infrastructure anymore. Maybe the project is no longer required, or the environment was needed only temporarily, etc.

