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

# Install PostgreSQL
postgresql_server_install 'postgresql-11' do
  version '11'
  initdb_locale 'en_US.UTF-8'
end

package %w(postgresql-11-postgis-2.5 postgis)

# Create databases for each web app
apps = search(:apps, "*:*")

apps.each do |app|
  db = app["database"]
  
  postgresql_user db["user"] do
    password db["password"]
  end

  postgresql_database db["database_name"] do
    owner db["user"]
  end
end

# Grant access to hosts on subnet
# host    all             all             10.1.0.1/16           md5
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
