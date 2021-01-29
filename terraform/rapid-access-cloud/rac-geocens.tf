# Set up OpenStack Provider for Rapid Access Cloud.
# Parameters are inherited from Environment Variables:
# 
# * `password`:    `OS_PASSWORD`
# * `auth_url`:    `OS_AUTH_URL`
# * `user_name`:   `OS_USERNAME`
# * `region`:      `OS_REGION_NAME`
# 
provider "openstack" {
  alias        = "geocens"
  delayed_auth = false
  tenant_name  = "geocens"
  tenant_id    = "28f40542f06b4dd5bbfdac4de659a380"
  auth_url     = "https://keystone-yyc.cloud.cybera.ca:5000/v3"
}

# "Internal" Security Group
# 
# ID: 355aee62-0d8b-4685-81ac-11bf57290cee
resource "openstack_networking_secgroup_v2" "internal" {
  name        = "internal"
  description = "Internal ports between instances, mysql, postgres, munin"
  provider    = openstack.geocens
}

# ID: ae85f80b-d170-4f7f-b902-61f600ef2330
resource "openstack_networking_secgroup_rule_v2" "internal_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.internal.id
  provider          = openstack.geocens
}

# ID: 36538b5b-50d3-4580-bea8-a31b70d9b2fc
resource "openstack_networking_secgroup_rule_v2" "internal_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.internal.id
  provider          = openstack.geocens
}

# ID: 4fcafebb-2b02-4610-8d93-097a4ff42215
resource "openstack_networking_secgroup_rule_v2" "internal_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 4949
  port_range_max    = 4949
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.internal.id
  provider          = openstack.geocens
}

# Allow pings
# ID: dfcc3016-3063-4eb6-8384-471807caa1ff
resource "openstack_networking_secgroup_rule_v2" "internal_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.internal.id
  provider          = openstack.geocens
}

# Allow ipv6 pings
# ID: 9e1c60ea-9abe-4cd9-a417-30242f073a11
resource "openstack_networking_secgroup_rule_v2" "internal_5" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "icmp"
  remote_ip_prefix  = "2605:fd00:4:1000:f816:3eff:fec3:c4d5/96"
  security_group_id = openstack_networking_secgroup_v2.internal.id
  provider          = openstack.geocens
}




# "Primary" Security Group
# 
# ID: 3ddf9fa8-12b1-490f-a7e2-8e529a922fd8
resource "openstack_networking_secgroup_v2" "primary" {
  name        = "primary"
  description = "Opens typical SSH, HTTP and HTTPS ports."
  provider    = openstack.geocens
}

# ID: aa9ad05f-d9da-438d-928d-9d81f5fb7164
resource "openstack_networking_secgroup_rule_v2" "primary_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.primary.id
  provider          = openstack.geocens
}

# ID: adfe3bb9-ff03-4406-906c-ac56b777e34d
resource "openstack_networking_secgroup_rule_v2" "primary_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.primary.id
  provider          = openstack.geocens
}

# ID: 9f8ea5d4-259f-4182-817f-d0543e2b02c2
resource "openstack_networking_secgroup_rule_v2" "primary_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.primary.id
  provider          = openstack.geocens
}

# ID: 860209cb-f495-4023-be3b-dd08bc33f690
resource "openstack_networking_secgroup_rule_v2" "primary_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2080
  port_range_max    = 2080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.primary.id
  provider          = openstack.geocens
}

# ID: 5eb10dd5-2a14-4923-a618-b3076b420c50
resource "openstack_networking_secgroup_rule_v2" "primary_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.primary.id
  provider          = openstack.geocens
}

# ID: 33d9a279-e823-44b3-af75-7479a3bb06ff
resource "openstack_networking_secgroup_rule_v2" "primary_6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8443
  port_range_max    = 8443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.primary.id
  provider          = openstack.geocens
}




###########
# INSTANCES
###########

resource "openstack_compute_instance_v2" "airport" {
  name            = "airport"
  image_id        = "a36ff0a8-1cb6-4d8f-b092-f00070ed9aac"
  flavor_id       = data.openstack_compute_flavor_v2.xlarge.id
  key_pair        = "James Desktop"
  security_groups = ["internal", "primary"]
  provider        = openstack.geocens

  metadata = {
    dns = "191f1.yyc.cybera.ca"
  }
}

output "airport_internal_ipv4" {
  value       = openstack_compute_instance_v2.airport.access_ip_v4
  description = "The private IP address of the instance."
}

resource "openstack_compute_instance_v2" "crowchild" {
  name            = "crowchild"
  image_id        = "a36ff0a8-1cb6-4d8f-b092-f00070ed9aac"
  flavor_id       = data.openstack_compute_flavor_v2.small.id
  key_pair        = "James Desktop"
  security_groups = ["internal", "primary"]
  provider        = openstack.geocens

  metadata = {
    dns = "18423.yyc.cybera.ca"
  }
}

output "crowchild_internal_ipv4" {
  value       = openstack_compute_instance_v2.crowchild.access_ip_v4
  description = "The private IP address of the instance."
}

resource "openstack_compute_instance_v2" "macleod" {
  name            = "macleod"
  image_id        = "499360f6-4b27-44b1-b346-2394a53a2a3e"
  flavor_id       = data.openstack_compute_flavor_v2.small.id
  key_pair        = "james-imac"
  security_groups = ["internal", "primary"]
  provider        = openstack.geocens

  metadata = {
  }
}

output "macleod_internal_ipv4" {
  value       = openstack_compute_instance_v2.macleod.access_ip_v4
  description = "The private IP address of the instance."
}

resource "openstack_compute_instance_v2" "shaganappi" {
  name            = "shaganappi"
  image_id        = "a36ff0a8-1cb6-4d8f-b092-f00070ed9aac"
  flavor_id       = data.openstack_compute_flavor_v2.medium.id
  key_pair        = "James Desktop"
  security_groups = ["internal", "primary"]
  provider        = openstack.geocens

  metadata = {
    dns = "18b1e.yyc.cybera.ca"
  }
}

output "shaganappi_internal_ipv4" {
  value       = openstack_compute_instance_v2.shaganappi.access_ip_v4
  description = "The private IP address of the instance."
}

resource "openstack_compute_instance_v2" "stoney" {
  name            = "stoney"
  image_id        = "7e5640f2-53fc-4474-bc77-d3666495218e"
  flavor_id       = data.openstack_compute_flavor_v2.tiny.id
  key_pair        = "James Desktop"
  security_groups = ["internal", "primary"]
  provider        = openstack.geocens

  metadata = {
  }
}

output "stoney_internal_ipv4" {
  value       = openstack_compute_instance_v2.stoney.access_ip_v4
  description = "The private IP address of the instance."
}
