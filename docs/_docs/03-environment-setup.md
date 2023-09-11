---
title:  "Environment setup"
permalink: /docs/environment-setup/
excerpt: "How to setup environment for terraform"
last_modified_at: 2023-02-09T08:48:05-04:00
toc: true
---

Like working with any other tool, it is important to setup your work environment correctly in order have a smooth experience while using the too. Running into environment issues while performing an important task is undesirable.



## Make sure terraform is installed
Just to be sure, run the command and see if you are able to see the version. If not, go back to the previous page and have it installed correctly
```
terraform -version
```

## Set up AWS access
The most popular use of terraform is to create cloud resources. We are going to use AWS as our target throughout this series. We will learn the principles and the same can applied to any other cloud provider as well.

### Check existing access
Try running `aws sts get-caller-identity`. If you are able to see a response like as below, you don't need to do the steps in this section.

### Install awscli
Note that `awscli` is not a requirement for terraform to work with AWS. It is just for our use to configure AWS access and verify things done by terraform. All terraform needs is an active AWS profile. If you have a working profile in `~/.aws/credentials` folder, you should be able to run terraform without an issue

It is just best that you visit the official AWS page to [download](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) `awscli`. Just make sure you choose the correct operating system and the CPU architecture. 

Once that is done, hopefully you are able to run `aws --version` and see an output like below:
```
aws --version
aws-cli/2.9.22 Python/3.11.1 Darwin/22.1.0 source/arm64 prompt/off
```

### Set up AWS credentials
There are multiple ways how AWS allows you to authenticate yourself to the AWS services. the most popular method is to use access keys and secret keys. If you not familiar with what those are, I recommend you check the official [documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds) around this. If you do have your keys to configure, go ahead and run:
```
aws configure --profile myuser
AWS Access Key ID [None]: AGSGYGHYJKDGEESWFG
AWS Secret Access Key [None]: pw7ptGbClwLP/4Ko8Iyl/g2tVi89bvWCQNOKROPR
Default region name [None]: us-east-1
Default output format [None]: json
```
As shown, put your credentials when asked.\
If you are unsure what inputs you need to provide, do check AWS official [documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

### Verify your credentials
Run the following command to see if you able to authenticate yourself against AWS:
```
aws sts get-caller-identity
```
If you get an error like:
```
Unable to locate credentials. You can configure credentials by running "aws configure".
```
Make sure you have a file `~/.aws/credentials` that has credentials you just entered. If it looks incorrect, you can edit this manually put information correctly. The file should look something like this:
```
[myuser]
aws_access_key_id = AGSG*******SWFG
aws_secret_access_key = pw7***************************PR
```
if you forgot to use `--profile myuser` while running `aws configure`, in the file you would see `[default]` instead of [myuser]. If you did use `--profile`, then do run `export AWS_PROFILE=myuser` before running `aws sts get-caller-identity`. The terraform also looks for the `AWS_PROFILE` environment variable to access AWS services. 

That's it. We are now ready to write our first terraform code.
