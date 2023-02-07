---
title:  "Why Terraform"
date:   2023-02-06 18:00:00 +0530
categories: tech devops terraform
---

## Why learn Terraform
The best way to understand why we need terraform is to understand the problems it solves. Here a few situations that you might have faced too:
- **Solving the infra-as-code problem:** You have a set of resources you want to create for multiple environments of your application.
This could be a `VPC`, a few `subnets`, its `routes`, etc. 
If you do it from the browser console, it will be difficult for you to replicate the exact same steps for two different environments for you application. 
To solve this we need to have a piece of code that can run with different parameters to create two (or more) replicas.
Terraform is entirely based on infra-as-code so it solves the first basic problem. Yes, there are other tools that work as infra-as-code, but not as efficiently as Terraform
- **The resource dependency issue:** Almost always we have to create multiple component that depend on each other. For example, before creating a subnet, we need to create the VPC within which the subnet will reside. So we chain the code in such a fashion that first the VPC is created, and we have to get the VPC id to pass on to the next step of creating the subnet. This passing of vpc id from one step to another is where terraform really shines. There are tools which can do this but terraform is just flawless. On the same dependency point, most of the tools will create the components sequentially. But terraform can intelligently detect what all components can be create in parallel so that the full stack is deployed faster.
- **The code runs on server X but not on Y:** A lot of tools depend upon the binaries present on the local server using which the deployment code is running. Whenever the deployment server changes, we have to get the correct binaries installed on the new system. For example, your code might be dependent upon a particular version of `python` or `psql` or something else. Terraform solves this issue by downloading the code/binaries needed by your code on-the-fly. So you won't have to worry about managing your pipeline code dependencies.
- **Knowing the impact of the code change:** There is always a situation where you have to update the existing code to make changes your infra/application deployments. When you make a change and run the code, you have keep your fingers crossed wondering if the change is going to destroy the universe. Terraform helps you here by provider a plan of what it is going to do on the target before it actually does that. So any destructive changes can be caught before any damage is done.

The list is certainly not exhaustive. These features are my personal favorites.

I come from a software development background and love to create code that reusable, repeatable, and modular. Terraform supports all this natively unlike some other tools in the market. Having said that, terraform is only good if you use it keeping in mind all the best practices. It will not solve all your problems magically. You need to get the basics right from the start if you want to maintain the code long term.

Disagree with something? The comment box is for you!