#
# Cookbook Name:: blackfoot
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

apt_update

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
  command "pg_dropcluster --stop #{node['postgresql']['version']} main &&\
   pg_createcluster -d \"#{node['postgresql']['data_directory']}\" \
  --locale en_US.UTF-8 --start #{node['postgresql']['version']} main"
  only_if { ::Dir.empty?(node['postgresql']['data_directory']) }
end

package %W(postgresql-#{node['postgresql']['version']}-postgis-2.5 postgis)
