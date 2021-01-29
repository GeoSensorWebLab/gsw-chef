# Terraform 0.13: Rapid Access Cloud

This sets up resources in the OpenStack cloud ran by Cybera, known as the "Rapid Access Cloud". We are using this cloud for the ArcticConnect and GeoCENS projects.

Before using these Terraform configurations, you must set certain shell environment variables with authentication information. In the web interface, select the "Compute" section in the navigation, then "API Access". Then download the "OpenStack RC File v3" and source that in your shell (Bash, Zsh) to configure authentication.

For Fish shell users, see the `rapid-access-cloud.fish` file included in this directory. Edit the username and region as necessary.

## Tenant: "geocens" Project

For managing secondary resources in the `geocens` OpenStack project.

### Resource Import

Most of these resources were pre-created via the web interface and had to be imported using their IDs, one example is given below.

```console
$ terraform import openstack_networking_secgroup_v2.primary 3ddf9fa8-12b1-490f-a7e2-8e529a922fd8
```

## S3 State Upgrade

The Terraform state had been kept locally in this directory, which is not compatible with sharing between developers. These are the steps taken to switch to state kept in GSW Lab's AWS S3 bucket.

```console
For fish shell:
$ set -x AWS_PROFILE gswlab
For bash/zsh:
$ export AWS_PROFILE=gswlab

Answer 'yes' to copy the current state to S3:
$ terraform init

Remove old state files:
$ mkdir oldstate
$ mv terraform.tfstate terraform.tfstate.backup oldstate/.

Review state, now in S3:
$ terraform plan

If it works fine, remove the old local state:
$ rm -rf oldstate
```

## 0.12 to 0.13 Upgrade

```console
$ sudo port select --set terraform terraform0.12
$ terraform init --upgrade=true
$ terraform apply

$ sudo port select --set terraform terraform0.13
$ terraform 0.13upgrade
$ terraform init --upgrade=true -reconfigure
$ terraform apply
```
