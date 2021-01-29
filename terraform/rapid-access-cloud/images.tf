#################
# Instance Images
#################
# Images used to serve as templates for instances

# ID: 877ce198-f6e2-4d06-8d3e-3344b16cb049
# Built on Fri Mar 8 21:19:13 UTC 2019
data "openstack_images_image_v2" "ubuntu1604" {
  name        = "Ubuntu 16.04"
  most_recent = true
}

# ID: d40fd617-b2ab-4cfc-950e-49a2e54c19f0
# Build on Thu Sep 24 03:56:12 UTC 2020
data "openstack_images_image_v2" "ubuntu1804" {
  name        = "Ubuntu 18.04"
  most_recent = true
}

# ID: ebcafd0b-9698-4adc-9e75-16e4e03082e2
# Build on Thu Sep 24 04:26:30 UTC 2020
data "openstack_images_image_v2" "ubuntu2004" {
  name        = "Ubuntu 20.04"
  most_recent = true
}
