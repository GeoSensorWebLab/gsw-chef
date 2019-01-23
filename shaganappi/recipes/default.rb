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

# Install ZFS
package 'zfsutils-linux'

# Check for database directory.
# If a ZFS dataset is used, then it must be set up MANUALLY.
directory node['postgresql']['data_directory'] do
  recursive true
  action :create
end

# Install PostgreSQL
postgresql_server_install "postgresql-#{node['postgresql']['version']}" do
  version node['postgresql']['version']
  initdb_locale 'en_US.UTF-8'
end

# Create the database cluster as the Chef resources cannot handle 
# changing to a different data directory without exploding
execute 'create postgres cluster' do
  command "pg_createcluster -d \"#{node['postgresql']['data_directory']}\" \
  --locale en_US.UTF-8 --start #{node['postgresql']['version']} main"
  only_if { ::Dir.empty?(node['postgresql']['data_directory']) }
end

package %W(postgresql-#{node['postgresql']['version']}-postgis-2.5 postgis)

# Create databases for each web app
apps = search(:apps, "*:*")

apps.each do |app|
  d_app = chef_vault_item('apps', app["id"])

  db = d_app["database"]
  
  postgresql_user db["user"] do
    password db["password"]
  end

  postgresql_database db["database_name"] do
    owner db["user"]
  end
end

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
