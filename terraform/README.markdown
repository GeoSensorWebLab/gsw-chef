# Terraform Configuration

This directory contains [Terraform](https://www.terraform.io) configurations for setting up cloud assets for the research lab. This is kept with the Chef configuration to be in "one place" for now.

## Why Terraform?

I trust the company who also made [Vagrant](https://www.vagrantup.com), a very useful virtual-machine orchestration tool. Terraform also works with multiple cloud platforms and we can use it to manage resources in Amazon Web Services as well as Cybera Rapid Access Cloud.

Terraform also has a cloud platform for tracking history and automatic deployments, but we will not be using it as our research lab is small. Instead we will only be using the command-line tool.

## Terraform Installation

A software tool is required to run the configuration scripts, and this tool can be [downloaded from Hashicorp](https://www.terraform.io/downloads.html). MacOS users may also install from Homebrew: `$ brew install terraform`.

## AWS Command Line Interface Profiles

I highly recommend setting up [named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) for the AWS command line interface. Create a specific `gswlab` profile with the key credentials you use for the lab, as a way to separate them from other AWS accounts you may be using.

Once set up, Terraform providers should then be using `profile = "gswlab"` to ensure the correct credentials are being used. For executing Terraform from the command line, an environment variable should be defined before running the `terraform` tool.

```terminal
$ export AWS_PROFILE=gswlab
$ terraform plan
```
