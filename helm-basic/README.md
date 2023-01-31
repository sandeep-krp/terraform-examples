## Description
If you are wondering how can you install a helm chart using a terraform, this terraform module is a right place to start.


## Prerequisites
- You already have access to a Kubernetes server. If you want to create a new local Kubernetes cluster, checkout [this]({% post_url 2023-01-29-run-minikube-with-podman %}) post.
- You have [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed

## TL;DR
```

```


## Background
Installing a basic helm chart on a Kubernetes cluster using terraform actually really easy. All you need to do is create a required provider configuration and create a `helm_release` kind of resource. Those two things are done in two files here in this code but it will work even if you put them in a single file. 
The `provider.tf` file container the provider configuration and points to your current context of kubernetes kube-config file. This is not ideal as you would image, but it is a something that would work for everything (hence used as an example)
The `grafana.tf` file contains the `helm_release` resource that defines where should it pull the chart from, which version, which namespace to deploy, configurations to pass, etc.

## Procedure
All you need to do is clone this code and run terraform apply:\
```
git clone git@github.com:sandeep-krp/terraform-examples.git
cd terraform-examples/helm-basic
terraform apply --auto-approve
```
If you don't want to hardcode the `~/.kube/config` file in your provider configuration, checkout the different ways to configure the `helm_provider` [here](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
