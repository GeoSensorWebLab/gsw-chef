# Terraform 0.14: Chef Infra Server for GSW Lab

This Terraform setup will create an EC2 instance to run self-hosted Chef Infra Server. This server then coordinates Chef Infra Client runs on various nodes we run in our research lab.

## Bootstrap

A sample Bash script with bootstrap commands is included (`bootstrap.bash`). I recommend using SCP to copy it to the node after it is created by Terraform, and running it manually to make sure it works. Maybe in the future it should be made more resilient and hooked directly into a Terraform post-setup script.

## Backups and AWS CLI

Backups for Chef Infra Server are stored in the `gswlab-chef-backups` bucket. Terraform will add a policy to grant access from the Chef Infra Server EC2 using role policies, so backups can be manually synchronized to and from S3 using the AWS CLI (no keys/secrets necessary).

To test the S3-policy, try listing the bucket:

```
$ aws s3 ls gswlab-chef-backups
                           PRE chef-infra-server/
```

## Restoring from Backup

After copying a backup `tgz` file from S3:

```
$ sudo chef-server-ctl restore chef-backup-2020-10-27-21-27-16.tgz
$ sudo chef-server-ctl reconfigure
```

**DISCLAIMER:** you MUST use the same version of Chef to restore the backup as the version that created the backup. Backups older than Dec 2020 require Chef Infra Server 12.

After restoring to the same version, Chef Infra Server can then be upgraded to a newer version.

The version for "Chef Infra Client" does not need to be the same; don't worry if it is a newer version. Let the all-in-one package handle Chef Infra Client.

## Import Log

Some resources already existed and had to be imported manually into Terraform.

```terminal
$ terraform import aws_route53_record.chef Z2XZGO0OWL7EL_chef.gswlab.ca_A
```
