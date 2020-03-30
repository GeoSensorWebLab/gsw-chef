# Terraform: Airport instance for Rapid Access Cloud

Will set up on Cybera Rapid Access Cloud (OpenStack):

* Volume for storing PostgreSQL database, tiles
* Instance for running Postgres/Apache/Renderd, etc

## Usage

Set up the shell with OpenStack credentials. This file can be downloaded from the RAC Dashboard, under the "Compute" and then "API Access" page as "OpenStack RC File v3".

```
$ source geocens-openrc.sh
```

Then run Terraform:

```
$ terraform init
$ terraform apply
```

For importing existing resources into Terraform:

```
$ terraform import <resource_type>.<resource_name> <openstack_id>
$ terraform import openstack_compute_instance_v2.airport 9af44f9d-3b1b-446b-b7ea-d916990f23ee
```
