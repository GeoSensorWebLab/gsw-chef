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

# Add render user for querying database
user node["edmonton"]["render_user"] do
  comment "renderd backend user"
  home "/home/#{node["edmonton"]["render_user"]}"
  manage_home true
  shell "/bin/false"
end

####################
# Install PostgreSQL
####################
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
  variables(settings: node["postgresql"]["settings"]["defaults"])
  notifies :reload, "service[postgresql]"
  not_if { node["postgresql"]["configured"] }
end

ruby_block "Store configuration flag" do
  block do
    node.normal["postgresql"]["configured"] = true
  end
  not_if { node["postgresql"]["configured"] }
end

directory node["postgresql"]["settings"]["defaults"]["data_directory"] do
  owner "postgres"
  group "postgres"
  mode "700"
  recursive true
  action :create
end

# Move the default database data directory to location defined in
# attributes
execute "move data directory" do
  command "cp -rp /var/lib/postgresql/12/main/* #{node["postgresql"]["settings"]["defaults"]["data_directory"]}/"
  only_if { ::Dir.empty?(node["postgresql"]["settings"]["defaults"]["data_directory"]) }
  notifies :restart, "service[postgresql]", :immediate
end

# Install GDAL and libraries from source to get full support for PostGIS

# Install Proj from source
ruby_block "Store PROJ build flag" do
  block do
    node.normal["edmonton"]["built_proj"] = true
  end
  not_if { node["edmonton"]["built_proj"] }
  action :nothing
end

proj_filename = FilenameFromURL.get_filename(node["proj"]["download_url"])
proj_datumgrid_filename = FilenameFromURL.get_filename(node["proj_datumgrid"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{proj_filename}" do
  source node["proj"]["download_url"]
  action :create
end

remote_file "#{Chef::Config["file_cache_path"]}/#{proj_datumgrid_filename}" do
  source node["proj_datumgrid"]["download_url"]
  action :create
end

directory "/opt/proj" do
  recursive true
  action :create
end

# Sqlite3 is needed for PROJ and GDAL
package %w(sqlite3 libsqlite3-dev)

bash "custom install proj" do
  code <<-EOH
    tar xf #{Chef::Config["file_cache_path"]}/#{proj_filename}
    cd proj-#{node["proj"]["version"]}
    unzip #{Chef::Config["file_cache_path"]}/#{proj_datumgrid_filename} -d data
    ./configure && make -j2 && make install
  EOH
  cwd "/opt/proj"
  not_if { node["edmonton"]["built_proj"] }
  notifies :run, "ruby_block[Store PROJ build flag]", :immediate
end

# Install GDAL from source to fix PostgreSQL 12 issues
ruby_block "Store GDAL build flag" do
  block do
    node.normal["edmonton"]["built_gdal"] = true
  end
  not_if { node["edmonton"]["built_gdal"] }
  action :nothing
end

gdal_filename = FilenameFromURL.get_filename(node["gdal"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{gdal_filename}" do
  source node["gdal"]["download_url"]
  action :create
end

directory "/opt/gdal" do
  recursive true
  action :create
end

bash "custom install gdal" do
  code <<-EOH
    tar xf #{Chef::Config["file_cache_path"]}/#{gdal_filename}
    cd gdal-#{node["gdal"]["version"]}
    
  EOH
  # ./configure --with-proj=/usr/local && make -j2 && make install
  cwd "/opt/gdal"
  not_if { node["edmonton"]["built_gdal"] }
  notifies :run, "ruby_block[Store GDAL build flag]", :immediate
end

# Install PostGIS
package %w(postgresql-12-postgis-3 postgresql-12-postgis-3-scripts)

osm2pgsql_dir = "/opt/osm2pgsql"

###################
# Install osm2pgsql
###################
directory osm2pgsql_dir do
  recursive true
  action :create
end

git osm2pgsql_dir do
  depth 1
  repository "https://github.com/openstreetmap/osm2pgsql.git"
  reference "1.2.1"
end

package %w(make cmake g++ libboost-dev libboost-system-dev 
  libboost-filesystem-dev libexpat1-dev zlib1g-dev
  libbz2-dev libpq-dev libproj-dev lua5.2 liblua5.2-dev)


bash "custom install osm2pgsql" do
  code <<-EOH
  mkdir build && cd build
  cmake ..
  make
  make install
  EOH
  cwd osm2pgsql_dir
  not_if { File.exists?("/usr/local/bin/osm2pgsql") }
end

###################
# Download Extracts
###################

extract_path = "#{node["edmonton"]["data_prefix"]}/extract"
directory extract_path do
  recursive true
  action :create
end

# Collect the downloaded extracts file paths
extract_file_list = []

node["edmonton"]["extracts"].each do |extract|
  extract_url          = extract["extract_url"]
  extract_checksum_url = extract["extract_checksum_url"]
  extract_file         = "#{extract_path}/#{::File.basename(extract_url)}"
  extract_file_list.push(extract_file)

  # Download the extract
  # Only runs if a) a downloaded file doesn't exist, 
  # b) a date requirement for the extract hasn't been set,
  # c) The remote file is newer than the extract date requirement
  remote_file extract_file do
    source extract_url
    only_if {
      edate = extract["extract_date_requirement"]
      !::File.exists?(extract_file) ||
      !edate.nil? && !edate.empty? && ::File.mtime(extract_file) < DateTime.strptime(edate).to_time
    }
    action :create
  end

  # If there is a checksum URL, download it and validate the extract
  # against the checksum provided by the source. Assumes md5.
  if !(extract_checksum_url.nil? || extract_checksum_url.empty?)
    extract_checksum_file = "#{extract_path}/#{::File.basename(extract_checksum_url)}"
    remote_file extract_checksum_file do
      source extract_checksum_url
      only_if {
        edate = extract["extract_date_requirement"]
        !::File.exists?(extract_checksum_file) ||
        !edate.nil? && !edate.empty? && ::File.mtime(extract_checksum_file) < DateTime.strptime(edate).to_time
      }
      action :create
    end

    # MD5 check is temporarily disabled as the MD5 checksum file has the
    # wrong reference file defined (it should be the "latest" file, but
    # is the dated PBF file instead.)
    # 
    # execute "validate extract" do
    #   command "md5sum --check #{extract_checksum_file}"
    #   cwd ::File.dirname(extract_checksum_file)
    #   user "root"
    # end
  end
end

# Join extracts into one large extract file
package "osmosis"

osmosis_args = extract_file_list.collect { |f| "--read-pbf-fast #{f}" }.join(" ")
osmosis_args += " " + (["--merge"] * (extract_file_list.length - 1)).join(" ")
merged_extract = "#{extract_path}/extracts-merged.pbf"

execute "combine extracts" do
  command "osmosis #{osmosis_args} --write-pbf \"#{merged_extract}\""
  timeout 3600
  not_if { ::File.exist?(merged_extract) }
end

#################################
# Optimize PostgreSQL for imports
#################################

# Only activate this configuration if osm2pgsql runs.
import_conf = node["postgresql"]["settings"]["defaults"].merge(node["postgresql"]["settings"]["import"])

template "import-configuration" do
  path "/etc/postgresql/12/main/postgresql.conf"
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0o644
  variables(settings: import_conf)
  notifies :reload, "service[postgresql]"
  action :nothing
end

##########################
# Create databases, tables
##########################

# Create database user for rendering
maps_server_user node["edmonton"]["render_user"] do
  cluster "12/main"
  password "render"
  superuser true
end

# For each of these projections, a PostgreSQL database will be created
# and osm2pgsql will import the OSM extract as that projection.
projections = [4326, 3857, 3573]

projections.each do |projection|
  database_name = "osm_#{projection}"

  maps_server_database database_name do
    cluster "12/main"
    owner node["edmonton"]["render_user"]
  end

  maps_server_extension "postgis" do
    cluster "12/main"
    database database_name
  end

  maps_server_extension "hstore" do
    cluster "12/main"
    database database_name
  end

  %w[geography_columns planet_osm_nodes planet_osm_rels planet_osm_ways raster_columns raster_overviews spatial_ref_sys].each do |table|
    maps_server_table table do
      cluster "12/main"
      database database_name
      owner node["edmonton"]["render_user"]
      permissions node["edmonton"]["render_user"] => :all
    end
  end

  ################
  # Import extract
  ################
  # A file is created after import to prevent re-import on subsequent
  # Chef runs.
  last_import = "#{node["edmonton"]["data_prefix"]}/extract/last-import-#{projection}"

  execute "import extract" do
    command <<-EOH
      sudo -u #{node["edmonton"]["render_user"]} osm2pgsql \
                --host /var/run/postgresql --create --slim --drop \
                --username #{node["edmonton"]["render_user"]} \
                --database #{database_name} -C #{node["edmonton"]["node_cache_size"]} \
                --number-processes #{node["edmonton"]["import_procs"]} \
                --hstore -E #{projection} -G #{merged_extract} &&
      date > #{last_import}
    EOH
    environment({
      PG_PASSWORD: "render"
    })
    cwd node["edmonton"]["data_prefix"]
    live_stream true
    user "root"
    timeout 86400
    notifies :create, "template[import-configuration]", :before
    not_if { ::File.exists?(last_import) }
  end

  # Clean up the database by running a PostgreSQL VACUUM and ANALYZE.
  # These improve performance and disk space usage, and therefore queries 
  # for generating tiles.
  # This should not take very long for small extracts (city/province
  # level). Continent/planet level databases will probably have to
  # increase the timeout.
  # A timestamp file is created after the run, and used to determine if
  # the resource should be re-run.
  post_import_vacuum_file = "#{node["edmonton"]["data_prefix"]}/extract/post-import-vacuum-#{projection}"

  maps_server_execute "VACUUM FULL VERBOSE ANALYZE" do
    cluster "12/main"
    database database_name
    timeout 86400
    not_if { ::File.exists?(post_import_vacuum_file) }
  end


  file post_import_vacuum_file do
    action :touch
    not_if { ::File.exists?(post_import_vacuum_file) }
  end
end

###########################################
# Import OSM Water Polygons into PostgreSQL
###########################################

maps_server_database "osm_water" do
  cluster "12/main"
  owner node["edmonton"]["render_user"]
end

maps_server_extension "postgis" do
  cluster "12/main"
  database "osm_water"
end

water_low_filename = FilenameFromURL.get_filename(node["osm_water_low"]["download_url"])

# Download the low-resolution OSM water shapefiles
remote_file "#{node["edmonton"]["data_prefix"]}/#{water_low_filename}" do
  source node["osm_water_low"]["download_url"]
  action :create
end

package "unzip"

bash "extract low-resolution water shapefiles" do
  cwd node["edmonton"]["data_prefix"]
  code <<-EOH
    unzip -o "#{node["edmonton"]["data_prefix"]}/#{water_low_filename}" -d .
  EOH
  not_if { ::File.exists?("#{node["edmonton"]["data_prefix"]}/simplified-water-polygons-split-3857") }
end

bash "import low-resolution water shapefiles into PostgreSQL" do
  cwd "#{node["edmonton"]["data_prefix"]}/simplified-water-polygons-split-3857"
  code <<-EOH
    ogr2ogr -f "PostgreSQL" PG:"host=localhost user=render dbname=osm_water password=render" \
      -lco GEOMETRY_NAME=wkb_geometry \
      -lco FID=ogc_fid \
      simplified_water_polygons.shp -nln osm_water_low
    touch pg_import
  EOH
  not_if { ::File.exists?("#{node["edmonton"]["data_prefix"]}/simplified-water-polygons-split-3857/pg_import") }
end

# Optimize PostgreSQL for tile serving
rendering_conf = node["postgresql"]["settings"]["defaults"].merge(node["postgresql"]["settings"]["tiles"])

template "tiles-configuration" do
  path "/etc/postgresql/12/main/postgresql.conf"
  source "postgresql.conf.erb"
  variables(settings: rendering_conf)
  notifies :reload, "service[postgresql]", :immediate
end
