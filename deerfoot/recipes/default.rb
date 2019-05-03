#
# Cookbook Name:: deerfoot
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
require "uri"

# Install OpenJDK
directory node["openjdk"]["prefix"] do
  recursive true
  action :create
end

jdk_uri = URI.parse(node["openjdk"]["download_url"])
src_filename = File.basename(jdk_uri.path)

remote_file "#{Chef::Config["file_cache_path"]}/#{src_filename}" do
  source node["openjdk"]["download_url"]
end

bash "extract JDK" do
  cwd node["openjdk"]["prefix"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{src_filename}" -C .
    EOH
end

java_home = "#{node["openjdk"]["prefix"]}/java/jdk-#{node["openjdk"]["version"]}"

# Install Tomcat

# Install GDAL

# Install GeoServer

# Install GeoServer GDAL Plugin

# Set up tomcat-native

# Optimize JVM
