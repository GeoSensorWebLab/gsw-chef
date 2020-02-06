#
# Cookbook Name:: edmonton
# Recipe:: geoserver
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
require "shellwords"
require "uri"

def filename_from_url(url)
  uri = URI.parse(url)
  File.basename(uri.path)
end

apt_update

##################
# Install Java JDK
##################
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

################
# Install Tomcat
################
tomcat_home = "#{node["tomcat"]["prefix"]}/apache-tomcat-#{node["tomcat"]["version"]}"

user node["tomcat"]["user"] do
  home node["tomcat"]["prefix"]
  manage_home false
end

group node["tomcat"]["user"] do
  members node["tomcat"]["user"]
end

directory node["tomcat"]["prefix"] do
  owner node["tomcat"]["user"]
  group node["tomcat"]["user"]
  recursive true
  action :create
end

tomcat_filename = filename_from_url(node["tomcat"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{tomcat_filename}" do
  source node["tomcat"]["download_url"]
end

bash "extract Tomcat" do
  cwd node["tomcat"]["prefix"]
  user node["tomcat"]["user"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{tomcat_filename}" -C .
    EOH
  not_if { ::File.exists?(tomcat_home) }
end

# Install modified web.xml with CORS filter enabled
cookbook_file "#{tomcat_home}/conf/web.xml" do
  source "tomcat/web.xml"
  owner node["tomcat"]["user"]
  group node["tomcat"]["user"]
end

# Source: https://gist.github.com/ovichiro/d24c53ce4902ef41cc208efeadd596b6
systemd_unit "tomcat.service" do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=syslog.target network.target

  [Service]
  Type=forking
  User=#{node["tomcat"]["user"]}
  Group=#{node["tomcat"]["user"]}

  Environment="JAVA_HOME=#{java_home}"
  Environment="CATALINA_PID=#{tomcat_home}/temp/tomcat.pid"
  Environment="CATALINA_HOME=#{tomcat_home}"
  Environment="CATALINA_BASE=#{tomcat_home}"
  Environment="CATALINA_OPTS="
  Environment="GEOSERVER_DATA_DIR=#{node["geoserver"]["data_directory"]}"
  Environment="LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{tomcat_home}/lib"
  Environment="JAVA_OPTS=-Dfile.encoding=UTF-8 -Djava.library.path=/usr/local/lib:#{tomcat_home}/lib -Xms#{node["tomcat"]["Xms"]} -Xmx#{node["tomcat"]["Xmx"]}"

  ExecStart=#{tomcat_home}/bin/startup.sh
  ExecStop=/bin/kill -15 $MAINPID

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end

# Create resource to refer to in other resource notifications
service "tomcat" do
  supports [:start, :stop, :restart]
  action :nothing
end
 
###################
# Install GeoServer
###################
default_geoserver_data = "#{tomcat_home}/webapps/geoserver/data"

# Create new GeoServer data directory
directory node["geoserver"]["data_directory"] do
  recursive true
  action :create
end

directory node["geoserver"]["prefix"] do
  recursive true
  action :create
end

geoserver_filename = filename_from_url(node["geoserver"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{geoserver_filename}" do
  source node["geoserver"]["download_url"]
end

package "unzip"

bash "extract GeoServer" do
  cwd "#{tomcat_home}/webapps"
  user node["tomcat"]["user"]
  code <<-EOH
    unzip -o "#{Chef::Config["file_cache_path"]}/#{geoserver_filename}" -d .
  EOH
  not_if { ::File.exists?("#{tomcat_home}/webapps/geoserver.war") }
  notifies :restart, "service[tomcat]"
end

# Relocate default geoserver data directory onto mounted volume.
# This resource will wait 120 seconds for Tomcat to start up GeoServer
# and have the default data directory created. Afterwards, Tomcat is
# restarted so that GeoServer re-reads the new data directory.
bash "Copy GeoServer data directory" do
  code <<-EOH
   while ! test -d "#{default_geoserver_data}"; do
      sleep 10
      echo "Waiting for GeoServer data directory to be created"
    done
    rmdir #{node["geoserver"]["data_directory"]}
    cp -rp #{default_geoserver_data} #{node["geoserver"]["data_directory"]}
  EOH
  not_if { File.exists?("#{node["geoserver"]["data_directory"]}/logs") }
  notifies :restart, "service[tomcat]"
end
 
###########################
# Install GeoServer Plugins
###########################
geoserver_vectortiles_filename = filename_from_url(node["geoserver"]["vectortiles_plugin"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{geoserver_vectortiles_filename}" do
  source node["geoserver"]["vectortiles_plugin"]["download_url"]
end

# Extract vector tiles plugin to GeoServer, waiting for Tomcat to start
# GeoServer and create the plugins directory first. If it doesn't exist
# within 120 seconds, then there is probably a problem and the chef 
# client should stop.
bash "extract GeoServer vector tiles plugin" do
  cwd node["geoserver"]["prefix"]
  code <<-EOH
    while ! test -d "#{tomcat_home}/webapps/geoserver/WEB-INF/lib"; do
      sleep 10
      echo "Waiting for GeoServer lib directory to be created"
    done
    rm -rf geoserver-vectortiles-plugin
    unzip "#{Chef::Config["file_cache_path"]}/#{geoserver_vectortiles_filename}" -d geoserver-vectortiles-plugin
    cp geoserver-vectortiles-plugin/*.jar "#{tomcat_home}/webapps/geoserver/WEB-INF/lib/."
    chown -R #{node["tomcat"]["user"]} #{tomcat_home}/webapps/geoserver/WEB-INF/lib
  EOH
  timeout 120
  not_if { ::File.exists?("#{tomcat_home}/webapps/geoserver/WEB-INF/lib/gs-vectortiles-#{node["geoserver"]["version"]}.jar") }
  notifies :restart, "service[tomcat]"
end
 
##########################
# Auto-Configure GeoServer
##########################

# Retrieve new GeoServer master password from chef-vault
if ChefVault::Item.vault?("passwords", "geoserver")
  geoserver_vault = ChefVault::Item.load("passwords", "geoserver")
else
  geoserver_vault = Chef::DataBagItem.load("passwords", "geoserver")
end

new_master_password = geoserver_vault["master_password"]
new_admin_password = geoserver_vault["password"]

ruby_block "Store master password update flag" do
  block do
    node.normal["geoserver"]["master_password_updated"] = true
  end
  not_if { node["geoserver"]["master_password_updated"] }
  action :nothing
end

ruby_block "Store admin password update flag" do
  block do
    node.normal["geoserver"]["admin_password_updated"] = true
  end
  not_if { node["geoserver"]["admin_password_updated"] }
  action :nothing
end

# Create XML change file for CURL request
template "#{node["geoserver"]["prefix"]}/changes.xml" do
  source "geoserver/changes.xml.erb"
  sensitive true
  variables({
    old_password: node["geoserver"]["default_master_password"],
    new_password: new_master_password
  })
end

# Change the default master password
bash "Update GeoServer master password" do
  code <<-EOH
    curl -u #{node["geoserver"]["default_master_username"]}:#{node["geoserver"]["default_master_password"]} \
      -XPUT -H "Content-type: text/xml" -d @changes.xml \
      http://localhost:8080/geoserver/rest/security/masterpw.xml
  EOH
  cwd node["geoserver"]["prefix"]
  sensitive true
  not_if { node["geoserver"]["master_password_updated"] }
  notifies :run, "ruby_block[Store master password update flag]", :immediate
end

# Change the default admin password
bash "Update GeoServer admin password" do
  code <<-EOH
    curl -u #{node["geoserver"]["default_master_username"]}:#{node["geoserver"]["default_master_password"]} \
      -XPUT -H "Content-type: application/json" -d '{ "newPassword": "#{Shellwords.escape(new_admin_password)}" }' \
      http://localhost:8080/geoserver/rest/security/self/password
  EOH
  cwd node["geoserver"]["prefix"]
  sensitive true
  not_if { node["geoserver"]["admin_password_updated"] }
  notifies :run, "ruby_block[Store admin password update flag]", :immediate
end

