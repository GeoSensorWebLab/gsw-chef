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

def filename_from_url(url)
  uri = URI.parse(url)
  File.basename(uri.path)
end

# Install OpenJDK
java_home = "#{node["openjdk"]["prefix"]}/jdk-#{node["openjdk"]["version"]}"

directory node["openjdk"]["prefix"] do
  recursive true
  action :create
end

jdk_filename = filename_from_url(node["openjdk"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{jdk_filename}" do
  source node["openjdk"]["download_url"]
end

bash "extract JDK" do
  cwd node["openjdk"]["prefix"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{jdk_filename}" -C .
    EOH
  not_if { ::File.exists?(java_home) }
end

# Install Tomcat
tomcat_home = "#{node["tomcat"]["prefix"]}/apache-tomcat-#{node["tomcat"]["version"]}"

directory node["tomcat"]["prefix"] do
  recursive true
  action :create
end

tomcat_filename = filename_from_url(node["tomcat"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{tomcat_filename}" do
  source node["tomcat"]["download_url"]
end

bash "extract Tomcat" do
  cwd node["tomcat"]["prefix"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{tomcat_filename}" -C .
    EOH
    not_if { ::File.exists?(tomcat_home) }
end

# Source: https://gist.github.com/ovichiro/d24c53ce4902ef41cc208efeadd596b6
systemd_unit 'tomcat.service' do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=syslog.target network.target

  [Service]
  Type=forking
  User=tomcat
  Group=tomcat

  Environment=JAVA_HOME=#{java_home}
  Environment=CATALINA_PID=#{tomcat_home}/temp/tomcat.pid
  Environment=CATALINA_HOME=#{tomcat_home}
  Environment=CATALINA_BASE=#{tomcat_home}
  Environment=CATALINA_OPTS=
  Environment="JAVA_OPTS=-Dfile.encoding=UTF-8 -Xms256m -Xmx2g"

  ExecStart=#{tomcat_home}/bin/startup.sh
  ExecStop=/bin/kill -15 $MAINPID

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable]
end

# Install GDAL

# Install GeoServer

# Install GeoServer GDAL Plugin

# Set up tomcat-native

# Optimize JVM
