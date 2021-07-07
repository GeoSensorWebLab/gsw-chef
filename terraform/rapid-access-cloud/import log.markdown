# Import Log

## 2021-07-07

Importing volumes in the `geocens` project into Terraform.

```
$ terraform import openstack_blockstorage_volume_v3.awm_volume 1dcfbc39-6fd9-4a79-b94e-d0d3ff6718ba
$ terraform import openstack_blockstorage_volume_v3.pg-store-22 65404b92-b8c2-483e-83f6-9233dfac31fa
$ terraform import openstack_blockstorage_volume_v3.pg-store-23 63dfe537-0844-49dc-8a73-69ee99252d99
$ terraform import openstack_blockstorage_volume_v3.pg-store-24 e9f56375-51a9-4814-8aac-623201703740
$ terraform import openstack_blockstorage_volume_v3.scholar-data 9960cc54-ad50-4c7a-8cd6-b5572766629d

$ terraform import openstack_compute_volume_attach_v2.airport_awm_storage 9af44f9d-3b1b-446b-b7ea-d916990f23ee/1dcfbc39-6fd9-4a79-b94e-d0d3ff6718ba
$ terraform import openstack_compute_volume_attach_v2.macleod_storage 2af31d80-05b0-4a72-ba8f-5744fc9bcb52/9960cc54-ad50-4c7a-8cd6-b5572766629d
$ terraform import openstack_compute_volume_attach_v2.shagnappi_va_1 ec5f38ee-5958-4163-bacf-311795088ce8/65404b92-b8c2-483e-83f6-9233dfac31fa
$ terraform import openstack_compute_volume_attach_v2.shagnappi_va_2 ec5f38ee-5958-4163-bacf-311795088ce8/63dfe537-0844-49dc-8a73-69ee99252d99
$ terraform import openstack_compute_volume_attach_v2.shagnappi_va_3 ec5f38ee-5958-4163-bacf-311795088ce8/e9f56375-51a9-4814-8aac-623201703740
```