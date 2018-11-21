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

# 3. Install PostgreSQL for Icinga 2

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

icinga_db_pass = chef_vault_item('secrets', 'icinga')['db_password']
# Use new password if none if found from the vault.
# This happens when using unencrypted databag fallback in test kitchen.
icinga_db_pass = new_password if (icinga_db_pass.nil? || icinga_db_pass.empty?)

# Create role in Postgres for icinga
postgresql_user 'icinga' do
  password icinga_db_pass
  sensitive true
end

# If the user already exists, the previous resource is skipped but we
# still need to update the password
postgresql_user 'icinga' do
  password icinga_db_pass
  sensitive true
  action :update
end

# Create DB for icinga
postgresql_database 'icinga' do
  owner 'icinga'
end

file '/root/.pgpass' do
  content "localhost:5432:icinga:icinga:#{icinga_db_pass}"
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
end

# Load the database for Icinga 2
bash 'Load Icinga 2 DB' do
  code <<-EOH
  psql -U icinga -d icinga -h localhost -p 5432 < /usr/share/icinga2-ido-pgsql/schema/pgsql.sql && \
  touch /opt/icinga_db_imported
  EOH
  sensitive true

  not_if { ::File.exists?('/opt/icinga_db_imported') }
end

# Update IDO Configuration
template '/etc/icinga2/features-available/ido-pgsql.conf' do
  source 'ido-pgsql.conf.erb'
  sensitive true
  variables({
    db: "icinga",
    host: "localhost",
    password: icinga_db_pass,
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
  notifies :restart, 'service[icinga2]', :immediately
end

# 4. Install Apache, PHP, Icinga Web 2
# https://icinga.com/docs/icingaweb2/latest/doc/02-Installation/
package %w(apache2 libapache2-mod-php icingaweb2 icingacli)

service 'apache2' do
  action :nothing
end

# Install Icinga Web 2 dependencies
package %w(php php-intl php-imagick php-gd php-curl php-mbstring php-pgsql)

ruby_block "Set default PHP timezone" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/php/7.2/apache2/php.ini")
    fe.insert_line_if_no_match(/^date.timezone = America\/Edmonton$/,
                               "date.timezone = America\/Edmonton")
    fe.write_file
  end
end

icingaweb2_db_pass = SecureRandom.alphanumeric(24)

# Create role in Postgres for icingaweb2
postgresql_user 'icingaweb2' do
  password icingaweb2_db_pass
  sensitive true
end

# If the user already exists, the previous resource is skipped but we
# still need to update the password
postgresql_user 'icingaweb2' do
  password icingaweb2_db_pass
  sensitive true
  action :update
end

# Create DB for icingaweb2
postgresql_database 'icingaweb2' do
  owner 'icingaweb2'
end

file '/root/.pgpass' do
  content "localhost:5432:icingaweb2:icingaweb2:#{icingaweb2_db_pass}"
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
end

# Load the database for Icinga Web 2
bash 'Load Icinga Web 2 DB' do
  code <<-EOH
  psql -U icingaweb2 -d icingaweb2 -h localhost -p 5432 < /usr/share/icingaweb2/etc/schema/pgsql.schema.sql && \
  touch /opt/icinga_web_db_imported
  EOH
  sensitive true

  not_if { ::File.exists?('/opt/icinga_web_db_imported') }
end

# TODO: secure this
icingaweb_password = "howdy"

# Use PHP on the node to hash the password, so the hash is compatible
# with Icinga Web 2.
bash "Add Icinga Web 2 User" do
  code <<-EOH
    /usr/bin/php -r "echo password_hash(\"#{icingaweb_password}\", PASSWORD_DEFAULT);" > /tmp/icingaweb2_pw && \
    /usr/bin/psql -U icingaweb2 -d icingaweb2 -h localhost -p 5432 \
    -c "INSERT INTO icingaweb_user (name, active, password_hash) \
    VALUES ('admin', 1, '$(cat /tmp/icingaweb2_pw)') \
    ON CONFLICT (name) \
    DO UPDATE SET password_hash = '$(cat /tmp/icingaweb2_pw)' \
    WHERE icingaweb_user.name = 'admin'" && \
    rm /tmp/icingaweb2_pw
    EOH
  sensitive true
end

template '/etc/apache2/sites-available/icingaweb2.conf' do
  source 'icingaweb2.conf.erb'
end

execute "Enable Icinga Web 2 Apache Site" do
  command 'a2ensite icingaweb2'
  notifies :restart, 'service[apache2]', :immediately
end

execute "Create Icinga Web 2 Configuration" do
  command 'icingacli setup config directory'
end

# Use Chef to build Icinga Web 2 configuration instead of using web
# configuration wizard
template '/etc/icingaweb2/authentication.ini' do
  source 'icingaweb2/authentication.ini.erb'
end

directory '/etc/icingaweb2/modules/monitoring' do
  recursive true
  action :create
end

template '/etc/icingaweb2/modules/monitoring/config.ini' do
  source 'icingaweb2/monitoring/config.ini.erb'
end

template '/etc/icingaweb2/modules/monitoring/instances.ini' do
  source 'icingaweb2/monitoring/instances.ini.erb'
end

template '/etc/icingaweb2/modules/monitoring/backends.ini' do
  source 'icingaweb2/monitoring/backends.ini.erb'
end

template '/etc/icingaweb2/roles.ini' do
  source 'icingaweb2/roles.ini.erb'
end

template '/etc/icingaweb2/config.ini' do
  source 'icingaweb2/config.ini.erb'
end

directory '/etc/icingaweb2/enabledModules' do
  action :create
end

template '/etc/icingaweb2/resources.ini' do
  source 'icingaweb2/resources.ini.erb'
  variables({
    db_host: "localhost",
    db_port: "5432",
    icingaweb2_db_name: "icingaweb2",
    icingaweb2_db_user: "icingaweb2",
    icingaweb2_db_pass: icingaweb2_db_pass,
    icinga2_db_name: "icinga",
    icinga2_db_user: "icinga",
    icinga2_db_pass: icinga_db_pass
  })
  sensitive true
end

directory '/etc/icingaweb2' do
  owner 'root'
  group 'icingaweb2'
  recursive true
end

execute "Enable Monitoring Module" do
  command 'icingacli module enable monitoring'
end

# Install HTTPS certificates
# Install Munin (primary controller)
# Install Munin Node (for this node/machine)
