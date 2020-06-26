# Set up OpenStack Provider for Rapid Access Cloud.
# Parameters are inherited from Environment Variables:
# 
# * `password`:    `OS_PASSWORD`
# * `auth_url`:    `OS_AUTH_URL`
# * `user_name`:   `OS_USERNAME`
# * `region`:      `OS_REGION_NAME`
# 
provider "openstack" {
  alias        = "arcticconnect"
  delayed_auth = false
  tenant_name  = "arcticconnect"
  tenant_id    = "f94d6233284241b381271db562171f38"
  auth_url     = "https://keystone-yyc.cloud.cybera.ca:5000/v3"
}

# "Internal" Security Group
# 
# ID: 355aee62-0d8b-4685-81ac-11bf57290cee
resource "openstack_networking_secgroup_v2" "ac_internal" {
  name        = "ac_internal"
  description = "Internal ports between instances, mysql, postgres, munin"
  provider    = openstack.arcticconnect
}

# ID: ae85f80b-d170-4f7f-b902-61f600ef2330
resource "openstack_networking_secgroup_rule_v2" "ac_internal_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.ac_internal.id
  provider          = openstack.arcticconnect
}

# ID: 36538b5b-50d3-4580-bea8-a31b70d9b2fc
resource "openstack_networking_secgroup_rule_v2" "ac_internal_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.ac_internal.id
  provider          = openstack.arcticconnect
}

# ID: 4fcafebb-2b02-4610-8d93-097a4ff42215
resource "openstack_networking_secgroup_rule_v2" "ac_internal_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 4949
  port_range_max    = 4949
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.ac_internal.id
  provider          = openstack.arcticconnect
}

# Allow pings
# ID: 86e47f75-57c7-4662-976b-3f292b97d291
resource "openstack_networking_secgroup_rule_v2" "ac_internal_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "10.1.0.0/16"
  security_group_id = openstack_networking_secgroup_v2.ac_internal.id
  provider          = openstack.arcticconnect
}

# Allow ipv6 pings
# ID: d583282a-1fea-447a-84d1-ff56704576e4
resource "openstack_networking_secgroup_rule_v2" "ac_internal_5" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "icmp"
  remote_ip_prefix  = "2605:fd00:4:1000:f816:3eff:fec3:c4d5/96"
  security_group_id = openstack_networking_secgroup_v2.ac_internal.id
  provider          = openstack.arcticconnect
}




# "Primary" Security Group
# 
# ID: 3ddf9fa8-12b1-490f-a7e2-8e529a922fd8
resource "openstack_networking_secgroup_v2" "ac_primary" {
  name        = "ac_primary"
  description = "Opens typical SSH, HTTP and HTTPS ports."
  provider    = openstack.arcticconnect
}

# ID: aa9ad05f-d9da-438d-928d-9d81f5fb7164
resource "openstack_networking_secgroup_rule_v2" "ac_primary_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ac_primary.id
  provider          = openstack.arcticconnect
}

# ID: adfe3bb9-ff03-4406-906c-ac56b777e34d
resource "openstack_networking_secgroup_rule_v2" "ac_primary_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ac_primary.id
  provider          = openstack.arcticconnect
}

# ID: 9f8ea5d4-259f-4182-817f-d0543e2b02c2
resource "openstack_networking_secgroup_rule_v2" "ac_primary_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ac_primary.id
  provider          = openstack.arcticconnect
}

# ID: 860209cb-f495-4023-be3b-dd08bc33f690
resource "openstack_networking_secgroup_rule_v2" "ac_primary_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2080
  port_range_max    = 2080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ac_primary.id
  provider          = openstack.arcticconnect
}

# ID: 5eb10dd5-2a14-4923-a618-b3076b420c50
resource "openstack_networking_secgroup_rule_v2" "ac_primary_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ac_primary.id
  provider          = openstack.arcticconnect
}

# ID: 33d9a279-e823-44b3-af75-7479a3bb06ff
resource "openstack_networking_secgroup_rule_v2" "ac_primary_6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8443
  port_range_max    = 8443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ac_primary.id
  provider          = openstack.arcticconnect
}




# INSTANCES
# 
resource "openstack_compute_instance_v2" "edmonton" {
  name            = "edmonton"
  image_id        = "7e5640f2-53fc-4474-bc77-d3666495218e"
  flavor_id       = "20c6e92e-5ae4-4032-9f12-d8783beb75ff"
  key_pair        = "james-laptop"
  security_groups = ["ac_internal", "ac_primary"]
  provider        = openstack.arcticconnect

  metadata = {
    dns = "1ce1d.yyc.cybera.ca"
  }
}

resource "openstack_compute_instance_v2" "blackfoot" {
  name            = "blackfoot"
  image_id        = "7e5640f2-53fc-4474-bc77-d3666495218e"
  flavor_id       = "3"
  key_pair        = "James Desktop"
  security_groups = ["ac_internal", "ac_primary"]
  provider        = openstack.arcticconnect

  metadata = {
    dns = "1b6d5.yyc.cybera.ca"
  }
}

resource "openstack_compute_instance_v2" "sarcee" {
  name            = "sarcee"
  image_id        = "7e5640f2-53fc-4474-bc77-d3666495218e"
  flavor_id       = "6d0115c2-ec4c-4458-b638-ce631186dc90"
  key_pair        = "James Desktop"
  security_groups = ["ac_internal", "ac_primary"]
  provider        = openstack.arcticconnect

  metadata = {
  }
}

resource "openstack_compute_instance_v2" "deerfoot" {
  name            = "deerfoot"
  image_id        = "d42c3ac7-a442-49f8-a5a2-63a01d83a911"
  flavor_id       = "6d0115c2-ec4c-4458-b638-ce631186dc90"
  key_pair        = "James Desktop"
  security_groups = ["ac_internal", "ac_primary"]
  provider        = openstack.arcticconnect

  metadata = {
  }
}

resource "openstack_compute_instance_v2" "barlow" {
  name            = "barlow"
  image_id        = "a36ff0a8-1cb6-4d8f-b092-f00070ed9aac"
  flavor_id       = "765eb725-abc5-4c9a-bf23-d8b0dca90f64"
  key_pair        = "James Desktop"
  security_groups = ["ac_internal", "ac_primary"]
  provider        = openstack.arcticconnect

  metadata = {
    dns = "186e9.yyc.cybera.ca"
  }
}