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

service "gost" do
  supports [:restart]
  action :nothing
end

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
  variables({
    external_uri: node["gost"]["external_uri"]
  })
  notifies :restart, "service[gost]", :delayed
end

directory node["gost"]["prefix"] do
  recursive true
  owner node["gost"]["user"]
  action :create
end

execute "make gost executable" do
  command "chmod +x #{node["gost"]["prefix"]}/linux64/gost"
end

template "/etc/systemd/system/gost.service" do
  source "gost.service.erb"
  variables({
    prefix: node["gost"]["prefix"],
    user: node["gost"]["user"]
  })
end

execute "reload systemd daemon" do
  command "systemctl daemon-reload"
end

service "gost" do
  action [:enable, :start]
end

###############
# Install nginx
###############

package %w(nginx-full)

service "nginx" do
  supports [:start, :stop, :restart, :reload]
  action :nothing
end

template "/etc/nginx/sites-available/gost" do
  source "nginx-gost.conf.erb"
  notifies :reload, "service[nginx]"
end

link "/etc/nginx/sites-enabled/gost" do
  to "/etc/nginx/sites-available/gost"
end

##########################
# Install data transloader
##########################

tl_home = "/home/transloader"
tl_user = "transloader"

user tl_user do
  home tl_home
  shell "/bin/bash"
end

directory tl_home do
  owner tl_user
  action :create
end

file "#{tl_home}/.bashrc" do
  content <<-EOH
  export GEM_HOME="#{tl_home}/.ruby"
  export GEM_PATH="#{tl_home}/.ruby/gems"
  export PATH="#{tl_home}/.ruby/bin:$PATH"
  EOH
  owner tl_user
end

directory "#{tl_home}/.ruby" do
  owner tl_user
  recursive true
  action :create
end

directory "/opt/data-transloader" do
  owner tl_user
  recursive true
  action :create
end

git "/opt/data-transloader" do
  repository "https://github.com/GeoSensorWebLab/data-transloader"
  user tl_user
end

package %w(ruby ruby-dev build-essential patch zlib1g-dev liblzma-dev)

# The default RubyGems version has issues running bundler (2019-06)
execute "Update RubyGems" do
  command "gem update --system"
end

bash "install transloader deps" do
  cwd "/opt/data-transloader"
  code <<-EOH
  gem install bundler
  bundle install
  EOH
  environment({
    GEM_HOME: "#{tl_home}/.ruby",
    GEM_PATH: "#{tl_home}/.ruby/gems",
    PATH: "#{tl_home}/.ruby/bin:#{ENV["PATH"]}"
  })
  user tl_user
end

# Set up data storage
cache_dir = "/srv/data"
directory cache_dir do
  owner tl_user
  action :create
end

# Set up log directory
directory "/srv/logs" do
  owner tl_user
  action :create
end

# Install automatic transloading scripts.
# This will read a list of stations from the command line and run an ETL
# on them.
# This version differs from the original version; in this version it does
# not read a TXT file and instead the list of stations is piped directly
# into the tool.
template "#{tl_home}/auto-metadata" do
  source "auto-metadata.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cachedir: cache_dir,
    logdir: "/srv/logs",
    sta_endpoint: "http://localhost:8080/v1.0/",
    workdir: "/opt/data-transloader"
  })
end

template "#{tl_home}/auto-transload" do
  source "auto-transload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cachedir: cache_dir,
    logdir: "/srv/logs",
    sta_endpoint: "http://localhost:8080/v1.0/",
    workdir: "/opt/data-transloader"
  })
end

template "#{tl_home}/transload-dg" do
  source "transload-dg.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cachedir: cache_dir,
    logdir: "/srv/logs",
    sta_endpoint: "http://localhost:8080/v1.0/",
    stations: node["transloader"]["data_garrison_stations"],
    workdir: "/opt/data-transloader"
  })
end

############################
# Run initial metadata fetch
############################

# ENVIRONMENT CANADA
# We use the "creates" property to prevent re-running this resource
node["transloader"]["environment_canada_stations"].each do |stn|
  bash "import Environment Canada station #{stn} metadata" do
    code <<-EOH
      ruby transload get metadata --source environment_canada \
        --station #{stn} --cache "#{cache_dir}"
      ruby transload put metadata --source environment_canada \
        --station #{stn} --cache "#{cache_dir}" \
        --destination "http://localhost:8080/v1.0/"
    EOH
    creates "#{cache_dir}/environment_canada/metadata/#{stn}.json"
    cwd "/opt/data-transloader"
    environment({
      GEM_HOME: "#{tl_home}/.ruby",
      GEM_PATH: "#{tl_home}/.ruby/gems",
      PATH: "#{tl_home}/.ruby/bin:#{ENV["PATH"]}"
    })
    user tl_user
  end
end

# DATA GARRISON
# Install jq so we can modify the station parameters before uploading
# the station metadata.
package %w(jq)

node["transloader"]["data_garrison_stations"].each do |stn|
  metadata_file = "#{cache_dir}/data_garrison/metadata/#{stn["user_id"]}/#{stn["station_id"]}.json"
  
  # Note that jq must write to a temp file because it does not support
  # in-place editing.
  bash "import Data Garrison station #{stn["station_id"]} metadata" do
    code <<-EOH
      ruby transload get metadata --source data_garrison \
        --user #{stn["user_id"]} --station #{stn["station_id"]} --cache "#{cache_dir}"
      jq '.latitude = "#{stn["latitude"]}" | .longitude = "#{stn["longitude"]}" | .timezone_offset = "#{stn["timezone_offset"]}"' "#{metadata_file}" > "#{metadata_file}.temp"
      mv "#{metadata_file}.temp" "#{metadata_file}"
      ruby transload put metadata --source data_garrison \
        --user #{stn["user_id"]} --station #{stn["station_id"]} --cache "#{cache_dir}" \
        --destination "http://localhost:8080/v1.0/"
    EOH
    creates metadata_file
    cwd "/opt/data-transloader"
    environment({
      GEM_HOME: "#{tl_home}/.ruby",
      GEM_PATH: "#{tl_home}/.ruby/gems",
      PATH: "#{tl_home}/.ruby/bin:#{ENV["PATH"]}"
    })
    user tl_user
  end
end

######################
# Schedule transloader
######################

file "#{tl_home}/ec-stations" do
  content node["transloader"]["environment_canada_stations"].join(" ")
  owner tl_user
end

cron_d "ec_transloader" do
  action :create
  minute "5"
  user tl_user
  shell "/bin/bash"
  environment({
    GEM_HOME: "#{tl_home}/.ruby",
    GEM_PATH: "#{tl_home}/.ruby/gems"
  })
  command %W{
    cat $HOME/ec-stations | $HOME/auto-transload
  }.join(" ")
end

cron_d "dg_transloader" do
  action :create
  minute "*/15"
  user tl_user
  shell "/bin/bash"
  environment({
    GEM_HOME: "#{tl_home}/.ruby",
    GEM_PATH: "#{tl_home}/.ruby/gems"
  })
  command %W{
    $HOME/transload-dg
  }.join(" ")
end

# Set up log rotation
template "/etc/logrotate.d/auto-transload" do
  source "transloader-logrotate.erb"
  variables({
    logdir: "/srv/logs",
    user: tl_user
  })
end

########################
# Install Sensors Web UI
########################

include_recipe "nodejs::default"

webui_dir = "/opt/community-sensorweb"

directory webui_dir do
  owner tl_user
  action :create
end

git webui_dir do
  repository "https://github.com/GeoSensorWebLab/community-sensorweb"
  user tl_user
end

execute "Install npm dependencies" do
  cwd webui_dir
  user tl_user
  environment({ 
    HOME: tl_home, 
    USER: tl_user 
  })
  command "npm install"
end

# Customize URL for STA connection
template "#{webui_dir}/config/environment.js" do
  source "sensorweb-env.js.erb"
  variables({
    sta_url: node["gost"]["external_uri"]
  })
  owner tl_user
end

execute "Build site to static files" do
  cwd webui_dir
  user tl_user
  environment({ 
    HOME: tl_home, 
    USER: tl_user 
  })
  command "node_modules/.bin/ember build --environment production"
end

# Set up nginx virtual host
template "/etc/nginx/sites-available/sensorweb" do
  source "nginx-sensorweb.conf.erb"
  variables({
    root: "#{webui_dir}/dist"
  })
  notifies :reload, "service[nginx]"
end

link "/etc/nginx/sites-enabled/sensorweb" do
  to "/etc/nginx/sites-available/sensorweb"
end

# Delete default nginx site to not conflict with sensorweb site.
file "/etc/nginx/sites-enabled/default" do
  action :delete
end
