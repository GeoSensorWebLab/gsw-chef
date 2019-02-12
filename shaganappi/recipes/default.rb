#
# Cookbook Name:: shaganappi
# Recipe:: default
#
# Copyright 2019 GeoSensorWeb Lab, University of Calgary
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

chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

# Install ZFS
package 'zfsutils-linux'

# Check for database directory.
# If a ZFS dataset is used, then it must be set up MANUALLY.
directory node['postgresql']['data_directory'] do
  recursive true
  mode '0700'
  action :create
end

# Install PostgreSQL
postgresql_server_install "postgresql-#{node['postgresql']['version']}" do
  version node['postgresql']['version']
  initdb_locale 'en_US.UTF-8'
end

# Update permissions on database directory for postgres
directory node['postgresql']['data_directory'] do
  recursive true
  owner 'postgres'
  group 'postgres'
  mode '0700'
  action :create
end

# Create the database cluster as the Chef resources cannot handle 
# changing to a different data directory without exploding
execute 'create postgres cluster' do
  command "pg_createcluster -d \"#{node['postgresql']['data_directory']}\" \
  --locale en_US.UTF-8 --start #{node['postgresql']['version']} main"
  only_if { ::Dir.empty?(node['postgresql']['data_directory']) }
end

package %W(postgresql-#{node['postgresql']['version']}-postgis-2.5 postgis)

# Grant access to hosts on subnet
# 10.1.0.1 to 10.1.255.255
postgresql_access 'subnet_access' do
  comment       'Access for servers on subnet'
  access_type   'host'
  access_db     'all'
  access_user   'all'
  access_addr   '10.1.0.1/16'
  access_method 'md5'
end

service 'postgresql' do
  action :restart
end

# Install pgbackrest
package 'pgbackrest'

# Install dependencies for pgbackrest S3 support
package %w(libio-socket-ssl-perl libxml-libxml-perl)

# Load S3 Secret Key from Chef Vault. If it is unavailable, disable S3
# support. Loading secrets from unencrypted data bags is intentionally
# not supported.

# Use these values if no encrypted vault is available.
s3_details = {
  enabled: false
}
repo_path = '/db-pool/pgbackrest'

if ChefVault::Item.vault?('secrets', 'pgbackrest')  && node['pgbackrest']['s3_enabled']

  s3_secrets = chef_vault_item('secrets', 'pgbackrest')['s3']

  s3_details = {
    enabled: true,
    bucket: s3_secrets["bucket"],
    endpoint: s3_secrets["endpoint"],
    access_key: s3_secrets["access_key"],
    secret_key: s3_secrets["secret_key"],
    region: s3_secrets["region"]
  }
  repo_path = "/pgbackrest/#{node.name}"
end

# Update pgbackrest configuration
cipher_pass = chef_vault_item('secrets', 'pgbackrest')['cipher_pass']

template '/etc/pgbackrest.conf' do
  source 'pgbackrest.conf.erb'
  mode '0640'
  owner 'postgres'
  group 'postgres'
  variables({
    repo_cipher_pass: cipher_pass,
    repo_path: repo_path,
    s3: s3_details,
    clusters: [{
      name: 'main',
      dbpath: node['postgresql']['data_directory']
    }]
  })
  sensitive true
end

# Create pgbackrest repository
directory '/db-pool/pgbackrest' do
  owner 'postgres'
  group 'postgres'
  mode '0750'
end

postgresql_server_conf 'archiving' do
  version node['postgresql']['version']
  data_directory node['postgresql']['data_directory']
  additional_config({
    "archive_command"  => "pgbackrest --stanza=main archive-push %p",
    "archive_mode"     => true,
    "listen_addresses" => "*",
    "log_line_prefix"  => "",
    "max_wal_senders"  => 3,
    "wal_level"        => "hot_standby"
  })
  notifies :reload, 'service[postgresql]', :immediately
end

execute 'create pgbackrest stanza' do
  command 'pgbackrest --stanza=main stanza-create'
  user 'postgres'
  group 'postgres'
end

execute 'check pgbackrest configuration' do
  command 'pgbackrest --stanza=main check'
  user 'postgres'
  group 'postgres'
end

template '/etc/cron.d/pgbackrest' do
  source 'pgbackrest.cron'
  owner 'root'
  group 'root'
end

# Create databases for each web app.
# This needs to happen after archiving has been enabled.
apps = search(:apps, "*:*")

apps.each do |app|
  begin
    d_app = chef_vault_item('apps', app["id"])
  rescue ChefVault::Exceptions::SecretDecryption
    # If we cannot decrypt, then skip the item
    next
  end

  db = d_app["database"]
  
  # Check if the search item is the vault item, as opposed to the 
  # keys for that item
  if db
    postgresql_user db["user"] do
      password db["password"]
      sensitive true
    end

    postgresql_database db["database_name"] do
      owner db["user"]
    end
  end
end

# Install NTP for local clock synchronization
package 'ntp'

# Install/Configure Munin Node Agent
package 'munin-node'

# Install/Configure Munin Node (for this node/machine)
# libwww-perl enables Apache plugins for Munin
package 'libwww-perl'

# libdbd-pg-perl enables Postgresql plugins for Munin
package 'libdbd-pg-perl'

execute 'update munin-node configuration' do
  command 'munin-node-configure --shell | sh'
end

# Servers that are allowed to connect to this munin-node instance
servers = search(:node, "name:crowchild")

template '/etc/munin/munin-node.conf' do
  source 'munin-node.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(servers: servers)
end

service 'munin-node' do
  action :restart
end
