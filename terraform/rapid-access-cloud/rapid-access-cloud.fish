#!/usr/bin/env fish

# To use an OpenStack cloud you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/tenant has
# access to - such as Compute, Image Service, Identity, Object Storage, Block
# Storage, and Networking (code-named nova, glance, keystone, swift,
# cinder, and neutron).
#
# *NOTE*: Using the 3 *Identity API* does not necessarily mean any other
# OpenStack API is version 3. For example, your cloud provider may implement
# Image API v1.1, Block Storage API v2, and Compute API v2.0. OS_AUTH_URL is
# only for the Identity API served through keystone.
set --export OS_AUTH_URL 'https://keystone-yyc.cloud.cybera.ca:5000/v3'

# With the addition of Keystone we have standardized on the term **project**
# as the entity that owns the resources.
set --export OS_PROJECT_ID 28f40542f06b4dd5bbfdac4de659a380

set --export OS_USER_DOMAIN_NAME "Default"

# unset v2.0 items in case set
set --erase OS_TENANT_ID
set --erase OS_TENANT_NAME

# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
set --export OS_USERNAME "YOUR-EMAIL-HERE@example.com"

# With Keystone you pass the keystone password.
echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
read --silent --export OS_PASSWORD

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
#
# Region must be "Calgary" or "Edmonton"!
set --export OS_REGION_NAME "Calgary"

set --export OS_INTERFACE public
set --export OS_IDENTITY_API_VERSION 3
