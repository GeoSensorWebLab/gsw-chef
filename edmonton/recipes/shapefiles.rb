#
# Cookbook Name:: edmonton
# Recipe:: shapefiles
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
package "unzip"

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

osm_water_filename = FilenameFromURL.get_filename(node["osm_water"]["download_url"])

# Download the high-resolution OSM water shapefiles
remote_file "#{node["edmonton"]["data_prefix"]}/#{osm_water_filename}" do
  source node["osm_water"]["download_url"]
  action :create
end

bash "extract OSM water shapefiles" do
  cwd node["edmonton"]["data_prefix"]
  code <<-EOH
    unzip -o "#{node["edmonton"]["data_prefix"]}/#{osm_water_filename}" -d .
  EOH
  not_if { ::File.exists?("#{node["edmonton"]["data_prefix"]}/water-polygons-split-4326") }
end

bash "import OSM water shapefiles into PostgreSQL in EPSG:4326" do
  cwd "#{node["edmonton"]["data_prefix"]}/water-polygons-split-4326"
  code <<-EOH
    ogr2ogr -f "PostgreSQL" PG:"host=localhost user=render dbname=osm_water password=render" \
      -lco GEOMETRY_NAME=wkb_geometry \
      -lco FID=ogc_fid \
      water_polygons.shp -nln osm_water_4326 && \
    touch pg_import_4326
  EOH
  not_if { ::File.exists?("#{node["edmonton"]["data_prefix"]}/water-polygons-split-4326/pg_import_4326") }
end

##########################################################
# Import Natural Earth Data Ocean Polygons into PostgreSQL
##########################################################

maps_server_database "ne_water" do
  cluster "12/main"
  owner node["edmonton"]["render_user"]
end

maps_server_extension "postgis" do
  cluster "12/main"
  database "ne_water"
end

ne_water_filename = FilenameFromURL.get_filename(node["ne_water"]["download_url"])

# Download the NE ocean shapefiles
remote_file "#{node["edmonton"]["data_prefix"]}/#{ne_water_filename}" do
  source node["ne_water"]["download_url"]
  action :create
end

bash "extract NE ocean shapefiles" do
  cwd node["edmonton"]["data_prefix"]
  code <<-EOH
    mkdir ne_110m_ocean
    unzip -o "#{node["edmonton"]["data_prefix"]}/#{ne_water_filename}" -d ne_110m_ocean
  EOH
  not_if { ::File.exists?("#{node["edmonton"]["data_prefix"]}/ne_110m_ocean") }
end

bash "import NE water shapefiles into PostgreSQL in EPSG:4326" do
  cwd "#{node["edmonton"]["data_prefix"]}/ne_110m_ocean"
  code <<-EOH
    ogr2ogr -f "PostgreSQL" PG:"host=localhost user=render dbname=ne_water password=render" \
      -lco GEOMETRY_NAME=wkb_geometry \
      -lco FID=ogc_fid \
      ne_110m_ocean.shp -nln ne_110m_ocean && \
    touch pg_import_4326
  EOH
  not_if { ::File.exists?("#{node["edmonton"]["data_prefix"]}/ne_110m_ocean/pg_import_4326") }
end
