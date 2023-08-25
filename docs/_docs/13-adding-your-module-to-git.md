---
title:  "Adding your modules to git"
permalink: /docs/adding-modules-to-git/
excerpt: "How to host terraform modules on git"
last_modified_at: 2023-08-24T20:48:05-04:00
toc: true
---

In the last chapter we saw why it is important to lock the version of the module which you are calling from your code. For an opensource module the versions are already available on git so it is easy to set the version. But what if you are going to maintain 10-15 different modules on your own. If you reference them locally, you will always refer the latest version.

```terraform
module "network" {
  source "./relative/path/to/local/directory"
  param1 = "x"
  .
}
```

The solution to this is to put your module on git and refer to them via git tags.

### Creating modules on git
The good news is that you don't have to do anything extra to make your simple module into a git module. Just commit the code on git and that's it. Terraform provides you an option to refer to a git module by default.

So let's turn the following code that we already have into a git module:
```shell
├── main.tf
├── network
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── variables.tf
```

With just some basic git knowledge, you will be able to push the above code to git repository like [this](https://github.com/sandeep-krp/terraform-examples/tree/gh-pages/basic). Note that you don't have worry about the directory structure under git. Terraform can refer to a sub-directory of git. 

Once you have the code on git, you can refer to it from a new code (in a new repo) as following:
```shell
├── env
│   ├── dev
│   │   ├── dev.tfbackend
│   │   └── dev.tfvars
│   └── test
│       ├── test.tfbackend
│       └── test.tfvars
└── module
    └── main.tf
```

The code in `main.tf`:
```terraform
module "git_example_module" {
  source = "git@github.com:sandeep-krp/terraform-examples.git//basic?ref=gh-pages"
}
```
Now this `main.tf` becomes your root module from which you are calling the module we have been creating up till now. This `main.tf` can be added to a completely different repository where you are storing the all the `tfvars` files for all the environments and keep the modules in a separate repository. Having generic modules in one repository and the `tfvars` in other repository makes the code more cleaner and easy to understand. Your modules should never have anything specific to an environment. They should only have the code that is common for all the environments. 

The code in the terraform module repository remains the same (under the `basic` folder in this case. Check the git URL):

```shell
.
├── main.tf
├── network
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── variables.tf
```

### Conclusion
Keeping your custom terraform modules in a separate repository is always a good idea. Make sure you are not adding environment specific code in the module. Do not put conditions like if the environment is `dev` then do this and when the environment is `test` then do this. Assume that the code can be called any number of times for creating n number of environments. If you write your modules in that fashion and then have separate repository to store `tfvars` then that would be the best approach.
