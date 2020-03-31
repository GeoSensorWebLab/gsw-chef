# Rapid Access Cloud

## Tenant: "geocens" Project

For managing secondary resources in the `geocens` OpenStack project.

To sync the state between RAC and local Terraform, use import to get the remote state for each resource. The IDs have been included in the TF files for reference.

```
$ terraform import openstack_networking_secgroup_v2.primary 3ddf9fa8-12b1-490f-a7e2-8e529a922fd8
```