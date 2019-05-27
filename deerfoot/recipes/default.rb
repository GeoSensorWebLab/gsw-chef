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

# Install fontconfig so Java apps properly load pages with fonts
package "fontconfig"

#################
# Install OpenJDK
#################

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
  source "web.xml"
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
  Environment="GDAL_DATA=/usr/local/share/gdal"
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
service 'tomcat' do
  supports [:start, :stop, :restart]
  action :nothing
end

##############
# Install GDAL
##############

# Install Proj4 for GDAL
package %w(libproj-dev proj-bin libproj12)

gdal_home = "#{node["gdal"]["prefix"]}/gdal-#{node["gdal"]["version"]}"
gdal_data = "#{gdal_home}/data"

directory node["gdal"]["prefix"] do
  recursive true
  action :create
end

gdal_filename = filename_from_url(node["gdal"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{gdal_filename}" do
  source node["gdal"]["download_url"]
end

bash "extract GDAL" do
  cwd node["gdal"]["prefix"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{gdal_filename}" -C .
  EOH
  not_if { ::File.exists?(gdal_home) }
end

package %w(build-essential swig)

# Install Apache Ant for Java GDAL bindings
ant_home = "#{node["ant"]["prefix"]}/apache-ant-#{node["ant"]["version"]}"
ant_filename = filename_from_url(node["ant"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{ant_filename}" do
  source node["ant"]["download_url"]
end

bash "extract ant" do
  cwd node["ant"]["prefix"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{ant_filename}" -C .
  EOH
  not_if { ::File.exists?(ant_home) }
end

# Compile GDAL, then install GDAL bindings for Java
bash "compile GDAL" do
  cwd gdal_home
  environment({
    "ANT_HOME" => ant_home,
    "JAVA_HOME" => java_home,
    "PATH" => "#{ant_home}/bin:#{ENV["PATH"]}"
  })
  code <<-EOH
    ./configure --with-java=#{java_home}
    make -j#{node["jobs"]}
    make install
    cd swig/java
    make
    make install
  EOH
  not_if "/usr/local/bin/gdal-config --version | grep -q '#{node["gdal"]["version"]}'"
end

###################
# Install GeoServer
###################
geoserver_data = "#{tomcat_home}/webapps/geoserver/data"

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
    unzip "#{Chef::Config["file_cache_path"]}/#{geoserver_filename}" -d .
  EOH
  not_if { ::File.exists?("#{tomcat_home}/webapps/geoserver.war") }
  notifies :restart, 'service[tomcat]'
end

###############################
# Install GeoServer GDAL Plugin
###############################

geoserver_gdal_filename = filename_from_url(node["geoserver"]["gdal_plugin"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{geoserver_gdal_filename}" do
  source node["geoserver"]["gdal_plugin"]["download_url"]
end

bash "extract GeoServer GDAL plugin" do
  cwd node["geoserver"]["prefix"]
  code <<-EOH
    unzip "#{Chef::Config["file_cache_path"]}/#{geoserver_gdal_filename}" -d geoserver-gdal-plugin
    cp geoserver-gdal-plugin/*.jar "#{tomcat_home}/webapps/geoserver/WEB-INF/lib/."
    cp "#{gdal_home}/swig/java/gdal.jar" "#{tomcat_home}/webapps/geoserver/WEB-INF/lib/."
    chown -R #{node["tomcat"]["user"]} #{tomcat_home}/webapps/geoserver/WEB-INF/lib
  EOH
  not_if { ::File.exists?("#{node["geoserver"]["prefix"]}/geoserver-gdal-plugin") }
end

#################################
# Install GeoServer GeoCSS Plugin
#################################

geoserver_css_filename = filename_from_url(node["geoserver"]["css_plugin"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{geoserver_css_filename}" do
  source node["geoserver"]["css_plugin"]["download_url"]
end

bash "extract GeoServer CSS plugin" do
  cwd node["geoserver"]["prefix"]
  code <<-EOH
    unzip "#{Chef::Config["file_cache_path"]}/#{geoserver_css_filename}" -d geoserver-css-plugin
    cp geoserver-css-plugin/*.jar "#{tomcat_home}/webapps/geoserver/WEB-INF/lib/."
    chown -R #{node["tomcat"]["user"]} #{tomcat_home}/webapps/geoserver/WEB-INF/lib
  EOH
  not_if { ::File.exists?("#{node["geoserver"]["prefix"]}/geoserver-css-plugin") }
end

######################
# Set up tomcat-native
######################

tomcat_native_home = "#{node["tomcat"]["prefix"]}/tomcat-native-#{node["tomcat-native"]["version"]}-src"
tomcat_native_filename = filename_from_url(node["tomcat-native"]["download_url"])

remote_file "#{Chef::Config["file_cache_path"]}/#{tomcat_native_filename}" do
  source node["tomcat-native"]["download_url"]
end

bash "extract tomcat-native" do
  cwd node["tomcat"]["prefix"]
  user node["tomcat"]["user"]
  code <<-EOH
    tar xzf "#{Chef::Config["file_cache_path"]}/#{tomcat_native_filename}" -C .
  EOH
  not_if { ::File.exists?(tomcat_native_home) }
end

package %w(libapr1 libapr1-dev libssl-dev)

# Compile tomcat-native
bash "compile tomcat-native" do
  cwd "#{tomcat_native_home}/native"
  environment({
    "JAVA_HOME" => java_home
  })
  code <<-EOH
    ./configure --prefix=#{tomcat_home}
    make -j#{node["jobs"]}
    make install
  EOH
  not_if { ::File.exists?("#{tomcat_home}/lib/libtcnative-1.so") }
  notifies :restart, 'service[tomcat]'
end

package %w(libtiff-tools)

# Install extra CRS definitions
cookbook_file "#{geoserver_data}/user_projections/epsg.properties" do
  source "epsg.properties"
  owner node["tomcat"]["user"]
  group node["tomcat"]["user"]
  notifies :restart, 'service[tomcat]'
end

#####################
# Customize GeoServer
#####################

# Remove default styles that we won't be using
%w(burg capitals giant_polygon grass_poly green lakes poi poly_landmarks
pophatch popshade rain restricted simpleRoads simple_streams tiger_roads).each do |style|
  file "#{geoserver_data}/styles/#{style}.sld" do
    ignore_failure true
    action :delete
  end

  file "#{geoserver_data}/styles/#{style}.xml" do
    ignore_failure true
    action :delete
  end
end

service "tomcat" do
  action :restart
end
