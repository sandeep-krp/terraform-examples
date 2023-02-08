---
title:  "Installation"
permalink: /docs/installing-terraform/
excerpt: "How to install terraform"
last_modified_at: 2023-02-07T08:48:05-04:00
toc: true
---

Its best if you use the official [installation link](https://developer.hashicorp.com/terraform/downloads) to install terraform on your machine. Make sure you understand which processing architecture your machine uses before downloading/installing terraform. You might run into issues if you download/install an incompatible version. You can use [this](https://pcguide101.com/cpu/what-is-my-processor-architecture/) guide to find out your CPU architecture.

For ease of access I am still going to mention quick commands for installation on MacOS and Ubuntu/Debian. For Windows, RHEL, FreeBSD, OpenBSD and Solaris visit the [official](https://developer.hashicorp.com/terraform/downloads) download page.

## Installation on MacOS
If you want to install terraform on an Apple machine, and you already have `brew` installed, the installation should be easy enough. You don't need to worry out the CPU architecture in this case. Brew will figure that out for you.\
Check if you have brew installed:
```
brew --version
```
If it does not throw any error and shows you a version, you are good to install terraform with:
```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
If you do not have brew installed, I highly recommend [installing](https://brew.sh) it as it is the best package manager for MacOS that helps you install almost everything you need for any kind of Software Development/DevOps activities.

## Installation on Ubuntu/Debian
For linux, you can either install using the package manager on your system, or download the binary and set it in your `PATH`. Just choose the the method you are most familiar with.

### Using package manager (apt)
```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
### Using the download method (choose one based on CPU Arch)
#### 386
```
mkdir -p ~/programs && wget ~/programs/terraform.zip https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_386.zip
 && unzip ~/programs/terraform.zip
```
#### AMD64
```
mkdir -p ~/programs && wget ~/programs/terraform.zip https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip && unzip ~/programs/terraform.zip
```

#### ARM
```
mkdir -p ~/programs && wget ~/programs/terraform.zip https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_arm.zip && unzip ~/programs/terraform.zip
```
#### ARM64
```
mkdir -p ~/programs && wget ~/programs/terraform.zip https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_arm64.zip
```

The above command will download the terraform zip file and unzip into `~/programs/terraform/`. You will have to put `~/programs/terraform/bin` path in your `PATH` variable. You can do so by:
```
echo "export PATH=~/programs/terraform/bin:$PATH" > ~/.bashrc
source ~/.bashrc
```
If you are able to run `terraform version` command, the installation is successful.
```
$ terraform -version
Terraform v1.3.7
on darwin_arm64
```
Again, if you are facing any error errors, while installations, carefully [check](https://pcguide101.com/cpu/what-is-my-processor-architecture/) your CPU architecture and use the [official](https://developer.hashicorp.com/terraform/downloads) download link for installation.
