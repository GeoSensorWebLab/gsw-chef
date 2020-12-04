# Chef Infra Server for GSW Lab

This Terraform setup will create an EC2 instance to run self-hosted Chef Infra Server. This server then coordinates Chef Infra Client runs on various nodes we run in our research lab.

## Import Log

Some resources already existed and had to be imported manually into Terraform.

```terminal
$ terraform import aws_route53_record.chef Z2XZGO0OWL7EL_chef.gswlab.ca_A
```
