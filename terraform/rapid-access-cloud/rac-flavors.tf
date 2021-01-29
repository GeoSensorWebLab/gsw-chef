#############################
# OpenStack Instance Flavours
#############################
# These are shared across multiple tenants.
data "openstack_compute_flavor_v2" "tiny" {
  disk  = 5
  ram   = 512
  vcpus = 1
}

data "openstack_compute_flavor_v2" "micro" {
  disk  = 5
  ram   = 1024
  vcpus = 1
}

data "openstack_compute_flavor_v2" "small" {
  disk  = 20
  ram   = 2048
  vcpus = 2
}

data "openstack_compute_flavor_v2" "medium" {
  disk  = 40
  ram   = 4096
  vcpus = 2
}

data "openstack_compute_flavor_v2" "large" {
  disk  = 40
  ram   = 8192
  vcpus = 4
}

data "openstack_compute_flavor_v2" "xlarge" {
  disk  = 40
  ram   = 16384
  vcpus = 8
}
