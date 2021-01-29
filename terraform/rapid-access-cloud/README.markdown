# Rapid Access Cloud

This sets up resources in the OpenStack cloud ran by Cybera, known as the "Rapid Access Cloud". We are using this cloud for the ArcticConnect and GeoCENS projects.

Before using these Terraform configurations, you must set certain shell environment variables with authentication information. In the web interface, select the "Compute" section in the navigation, then "API Access". Then download the "OpenStack RC File v3" and source that in your shell (Bash, Zsh) to configure authentication.

For Fish shell users, see the `rapid-access-cloud.fish` file included in this directory. Edit the username and region as necessary.

## Tenant: "geocens" Project

For managing secondary resources in the `geocens` OpenStack project.

### Resource Import

Most of these resources were pre-created via the web interface and had to be imported using their IDs, one example is given below.

```
$ terraform import openstack_networking_secgroup_v2.primary 3ddf9fa8-12b1-490f-a7e2-8e529a922fd8
```
