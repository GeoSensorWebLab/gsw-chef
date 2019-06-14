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
directory node["postgresql"]["data_directory"] do
  recursive true
  mode "0700"
  action :create
end

# Install PostgreSQL
postgresql_server_install "postgresql-#{node["postgresql"]["version"]}" do
  version node["postgresql"]["version"]
  initdb_locale "en_US.UTF-8"
end

# Update permissions on database directory for postgres
directory node["postgresql"]["data_directory"] do
  recursive true
  owner "postgres"
  group "postgres"
  mode "0700"
  action :create
end

# Create the database cluster as the Chef resources cannot handle 
# changing to a different data directory without exploding
execute "create postgres cluster" do
  command "pg_dropcluster --stop #{node["postgresql"]["version"]} main &&\
   pg_createcluster -d \"#{node["postgresql"]["data_directory"]}\" \
  --locale en_US.UTF-8 --start #{node["postgresql"]["version"]} main"
  only_if { ::Dir.empty?(node["postgresql"]["data_directory"]) }
end

package %W(postgresql-#{node["postgresql"]["version"]}-postgis-2.5 postgis)


##############
# Install GOST
##############

remote_file "#{Chef::Config["file_cache_path"]}/gost_ubuntu_x64.zip" do
  source node["gost"]["release"]
end

package "unzip"

# Use postgres owner so that statefile can be created later
directory node["gost"]["prefix"] do
  recursive true
  owner "postgres"
  action :create
end

execute "unzip GOST" do
  command "unzip #{Chef::Config["file_cache_path"]}/gost_ubuntu_x64.zip -d #{node["gost"]["prefix"]}"
  not_if { ::Dir.exist?("#{node["gost"]["prefix"]}/linux64") }
end

git "#{node["gost"]["prefix"]}/gost-db" do
  repository node["gost"]["database_repository"]
end

postgresql_user node["gost"]["user"] do
  sensitive true
end

postgresql_database node["gost"]["database"] do
  owner node["gost"]["user"]
end

execute "initialize GOST database" do
  command "psql #{node["gost"]["database"]} -f #{node["gost"]["prefix"]}/gost-db/gost_init_db.sql && \
  psql #{node["gost"]["database"]} -c 'alter schema \"v1\" owner to \"#{node["gost"]["user"]}\"' \
    -c 'grant all on database #{node["gost"]["database"]} to #{node["gost"]["user"]};' \
    -c 'grant all privileges on all tables in schema v1 to #{node["gost"]["user"]}' \
    -c 'grant all privileges on all sequences in schema v1 to #{node["gost"]["user"]}' && \
  touch #{node["gost"]["prefix"]}/database-import"
  user "postgres"
  not_if { ::File.exist?("#{node["gost"]["prefix"]}/database-import") }
end

user node["gost"]["user"] do
  home node["gost"]["prefix"]
end

postgresql_access "Allow gost system user" do
  access_type   "local"
  access_db     node["gost"]["database"]
  access_user   node["gost"]["user"]
  access_addr   nil
  access_method "ident"
end

template "#{node["gost"]["prefix"]}/linux64/config.yaml" do
  source "gost-config.yaml.erb"
  owner node["gost"]["user"]
end

directory node["gost"]["prefix"] do
  recursive true
  owner node["gost"]["user"]
  action :create
end

execute "make gost executable" do
  command "chmod +x #{node["gost"]["prefix"]}/linux64/gost"
end
