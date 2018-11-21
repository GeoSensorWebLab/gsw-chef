#
# Cookbook Name:: crowchild
# Recipe:: default
#
# Copyright 2018 GeoSensorWeb Lab, University of Calgary
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'securerandom'

include_recipe 'chef-vault'

# 1. Install Icinga Apt Repository
# https://packages.icinga.com/ubuntu/

apt_repository 'icinga' do
  uri 'http://packages.icinga.com/ubuntu'
  distribution 'icinga-bionic'
  components ['main']
  key 'https://packages.icinga.com/icinga.key'
end

# 2. Install Icinga 2
# https://icinga.com/docs/icinga2/latest/doc/02-getting-started/

package 'icinga2'

service 'icinga2' do
  action :nothing
end

# 3. Install PostgreSQL for Icinga Web 2

postgresql_server_install 'postgresql-10' do
  version '10'
end

package 'icinga2-ido-pgsql'

# Generate a random password, if one does not exist
new_password = SecureRandom.alphanumeric(24)

# Set up chef-vault secrets for DB password
chef_vault_secret 'icinga' do
  data_bag 'secrets'
  raw_data({ 'db_password' => new_password })
  admins 'admin'
  search '*:*'
  sensitive true
  action :create
end

postgres_password = chef_vault_item('secrets', 'icinga')['db_password']
# Use new password if none if found from the vault.
# This happens when using unencrypted databag fallback in test kitchen.
postgres_password = new_password if (postgres_password.nil? || postgres_password.empty?)

# Create role in Postgres for icinga
postgresql_user 'icinga' do
  password postgres_password
  sensitive true
end

# If the user already exists, the previous resource is skipped but we
# still need to update the password
postgresql_user 'icinga' do
  password postgres_password
  sensitive true
  action :update
end

# Create DB for icinga
postgresql_database 'icinga' do
  owner 'icinga'
end

file '/root/.pgpass' do
  content "localhost:5432:icinga:icinga:#{postgres_password}"
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
end

# Load the database for Icinga Web 2
bash 'Load Icinga Web 2 DB' do
  code <<-EOH
  psql -U icinga -d icinga -h localhost -p 5432 < /usr/share/icinga2-ido-pgsql/schema/pgsql.sql && \
  touch /opt/icinga_web_db_imported
  EOH
  sensitive false

  not_if { ::File.exists?('/opt/icinga_web_db_imported') }
end

# Update IDO Configuration
template '/etc/icinga2/features-available/ido-pgsql.conf' do
  source 'ido-pgsql.conf.erb'
  sensitive true
  variables({
    db: "icinga",
    host: "localhost",
    password: postgres_password,
    user: "icinga"
  })
end

# Enable IDO PostgreSQL module
execute "Enable IDO PostgreSQL module" do
  command "icinga2 feature enable ido-pgsql"
  notifies :restart, 'service[icinga2]', :immediately
end

# Enable Icinga 2 REST API
execute "able Icinga 2 REST API" do
  command "icinga2 api setup"
end

icingaweb_rest_password = SecureRandom.alphanumeric(24)

template '/etc/icinga2/conf.d/api-users.conf' do
  source 'api-users.conf.erb'
  sensitive true
  variables({
    root_password: SecureRandom.alphanumeric(24),
    users: [{
      name: 'icingaweb2',
      password: icingaweb_rest_password,
      permissions: ["status/query", "actions/*", "objects/modify/*", "objects/query/*"]
    }]
  })
end

# 4. Install HTTPS certificates
# 5. Icinga Web 2
# 6. Install Munin (primary controller)
# 7. Install Munin Node (for this node/machine)
