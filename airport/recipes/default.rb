#
# Cookbook Name:: airport
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

include_recipe 'maps_server::base_monitoring'
include_recipe 'maps_server::default'
include_recipe 'maps_server::openstreetmap_carto'
include_recipe 'maps_server::arcticwebmap'
include_recipe 'maps_server::monitoring'
include_recipe 'maps_server::mapproxy'

# Install old stylesheets, as renderd will cryptically fail without
# them.
%w(osm_3571 osm_3572 osm_3573 osm_3574 osm_3575 osm_3576).each do |id|
  cookbook_file "/srv/stylesheets/#{id}.xml.gz" do
    source "#{id}.xml.gz"
    mode "0755"
  end

  execute "gunzip #{id}" do
    command "gunzip #{id}.xml.gz"
    cwd "/srv/stylesheets"
    creates "/srv/stylesheets/#{id}.xml.gz"
  end
end

service "renderd" do
  action :restart
end
