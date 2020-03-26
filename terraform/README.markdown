# Terraform Configuration

This directory contains [Terraform](https://www.terraform.io) configurations for setting up cloud assets for the research lab. This is kept with the Chef configuration to be in "one place" for now.

## Why Terraform?

I trust the company who also made [Vagrant](https://www.vagrantup.com), a very useful virtual-machine orchestration tool. Terraform also works with multiple cloud platforms and we can use it to manage resources in Amazon Web Services as well as Cybera Rapid Access Cloud.

Terraform also has a cloud platform for tracking history and automatic deployments, but we will not be using it as our research lab is small. Instead we will only be using the command-line tool.

## Terraform Installation

A software tool is required to run the configuration scripts, and this tool can be [downloaded from Hashicorp](https://www.terraform.io/downloads.html). MacOS users may also install from Homebrew: `$ brew install terraform`.
