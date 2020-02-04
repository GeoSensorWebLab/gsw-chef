#
# Cookbook Name:: edmonton
# Recipe:: postgresql
#
# Copyright 2020 GeoSensorWeb Lab, University of Calgary
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

# Set locale
locale node["edmonton"]["locale"]

# Install PostgreSQL
# Use the PostgreSQL Apt repository for latest versions.
apt_repository "postgresql" do
  components    ["main"]
  distribution  "bionic-pgdg"
  key           "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
  uri           "http://apt.postgresql.org/pub/repos/apt/"
end

# Update Apt cache
apt_update "update" do
  action :update
end

package %w(postgresql-12 postgresql-client-12 postgresql-server-dev-12)

service "postgresql" do
  action :nothing
  supports :status => true, :restart => true, :reload => true
end

template "/etc/postgresql/12/main/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0o644
  variables(settings: node[:postgresql][:settings][:defaults])
  notifies :reload, "service[postgresql]"
  not_if { node[:postgresql][:configured] }
end

ruby_block "Store configuration flag" do
  block do
    node.normal[:postgresql][:configured] = true
  end
  not_if { node[:postgresql][:configured] }
end

directory node[:postgresql][:settings][:defaults][:data_directory] do
  owner "postgres"
  group "postgres"
  mode "700"
  recursive true
  action :create
end

# Move the default database data directory to location defined in
# attributes
execute "move data directory" do
  command "cp -rp /var/lib/postgresql/12/main/* #{node[:postgresql][:settings][:defaults][:data_directory]}/"
  only_if { ::Dir.empty?(node[:postgresql][:settings][:defaults][:data_directory]) }
  notifies :restart, "service[postgresql]", :immediate
end

# Install GDAL and libraries from source to get full support for PostGIS

# liblwgeom provides ST_MakeValid and similar.
package %w(liblwgeom-dev)

ruby_block "Store libspatialite build flag" do
  block do
    node.normal[:edmonton][:built_libspatialite] = true
  end
  not_if { node[:edmonton][:built_libspatialite] }
  action :nothing
end

bash "custom install libspatialite-dev" do
  code <<-EOH
  apt-get build-dep -y libspatialite-dev
  apt-get source libspatialite-dev
  cd spatialite-*
  sed -i 's/--enable-lwgeom=no/--enable-lwgeom=yes/g' debian/rules
  dpkg-buildpackage -us -uc
  dpkg -i ../*.deb
  apt-get install -f
  EOH
  cwd "/usr/local/src"
  not_if { node[:edmonton][:built_libspatialite] }
  notifies :run, "ruby_block[Store libspatialite build flag]", :immediate
end

package %w(gdal-bin gdal-data libgdal-dev libgdal20)

# Install PostGIS
package %w(postgresql-12-postgis-3 postgresql-12-postgis-3-scripts)

# Install osm2pgsql
directory "/opt/osm2pgsql" do
  recursive true
  action :create
end

git "/opt/osm2pgsql" do
  depth 1
  repository "https://github.com/openstreetmap/osm2pgsql.git"
  reference "1.2.1"
end

package %w(make cmake g++ libboost-dev libboost-system-dev 
  libboost-filesystem-dev libexpat1-dev zlib1g-dev
  libbz2-dev libpq-dev libproj-dev lua5.2 liblua5.2-dev)

