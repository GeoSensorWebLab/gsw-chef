# Set up OpenStack Provider for Rapid Access Cloud.
# Parameters are inherited from Environment Variables:
# 
# * `password`:    `OS_PASSWORD`
# * `auth_url`:    `OS_AUTH_URL`
# * `tenant_name`: `OS_PROJECT_NAME`
# * `user_name`:   `OS_USERNAME`
# * `region`:      `OS_REGION_NAME`
# 
provider "openstack" {
  delayed_auth = false
  auth_url = "https://keystone-yyc.cloud.cybera.ca:5000/v3"
}

resource "openstack_blockstorage_volume_v2" "awm_volume" {
  name = "awm_volume"
  size = 100
}

resource "openstack_compute_instance_v2" "airport" {
  name            = "airport"
  image_id        = "a36ff0a8-1cb6-4d8f-b092-f00070ed9aac"
  flavor_id       = "20c6e92e-5ae4-4032-9f12-d8783beb75ff"
  key_pair        = "James Desktop"
  security_groups = ["default", "open"]

  metadata = {
    dns = "191f1.yyc.cybera.ca"
  }
}

resource "openstack_compute_volume_attach_v2" "attached" {
  instance_id = openstack_compute_instance_v2.airport.id
  volume_id   = openstack_blockstorage_volume_v2.awm_volume.id
}
