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
require 'base64'
require 'securerandom'

apt_update

###############
# Install nginx
###############

package %w(nginx-full)

service "nginx" do
  supports [:start, :stop, :restart, :reload]
  action :nothing
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
  revision "v0.6.0"
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

# Install automatic transloading scripts, to be ran by AirFlow DAGs.
template "#{tl_home}/ec-download" do
  source "ec-download.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir: cache_dir,
    log_dir:   "/srv/logs",
    stations:  node["transloader"]["environment_canada_stations"],
    work_dir:  "/opt/data-transloader"
  })
end

template "#{tl_home}/ec-upload" do
  source "ec-upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir:    cache_dir,
    log_dir:      "/srv/logs",
    sta_endpoint: node["sensorthings"]["external_uri"],
    stations:     node["transloader"]["environment_canada_stations"],
    work_dir:     "/opt/data-transloader"
  })
end

# template "#{tl_home}/transload-dg" do
#   source "transload-dg.sh.erb"
#   owner tl_user
#   mode "0755"
#   variables({
#     cachedir: cache_dir,
#     logdir: "/srv/logs",
#     sta_endpoint: node["sensorthings"]["external_uri"],
#     stations: node["transloader"]["data_garrison_stations"],
#     workdir: "/opt/data-transloader"
#   })
# end

# Set up log rotation
template "/etc/logrotate.d/auto-transload" do
  source "transloader-logrotate.erb"
  variables({
    logdir: "/srv/logs",
    user: tl_user
  })
end

############################
# Run initial metadata fetch
############################

if node["sensorthings"]["auth_username"].nil?
  sensorthings_auth = ""
else
  sensorthings_auth = "--user '#{node["sensorthings"]["auth_username"]}:#{node["sensorthings"]["auth_password"]}'"
end

# ENVIRONMENT CANADA
# We use the "creates" property to prevent re-running this resource
node["transloader"]["environment_canada_stations"].each do |stn|
  bash "import Environment Canada station #{stn} metadata" do
    code <<-EOH
      ruby transload get metadata \
        --provider environment_canada \
        --station_id #{stn} \
        --cache "#{cache_dir}"

      ruby transload put metadata \
        --provider environment_canada \
        --station_id #{stn} \
        --cache "#{cache_dir}" \
        --destination "#{node["sensorthings"]["external_uri"]}" \
        #{sensorthings_auth}
    EOH
    creates "#{cache_dir}/v2/environment_canada/metadata/#{stn}.json"
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
# package %w(jq)

# node["transloader"]["data_garrison_stations"].each do |stn|
#   metadata_file = "#{cache_dir}/data_garrison/metadata/#{stn["user_id"]}/#{stn["station_id"]}.json"
  
#   # Note that jq must write to a temp file because it does not support
#   # in-place editing.
#   bash "import Data Garrison station #{stn["station_id"]} metadata" do
#     code <<-EOH
#       ruby transload get metadata --source data_garrison \
#         --user #{stn["user_id"]} --station #{stn["station_id"]} --cache "#{cache_dir}"
#       jq '.latitude = "#{stn["latitude"]}" | .longitude = "#{stn["longitude"]}" | .timezone_offset = "#{stn["timezone_offset"]}"' "#{metadata_file}" > "#{metadata_file}.temp"
#       mv "#{metadata_file}.temp" "#{metadata_file}"
#       ruby transload put metadata --source data_garrison \
#         --user #{stn["user_id"]} --station #{stn["station_id"]} --cache "#{cache_dir}" \
#         --destination "#{node["sensorthings"]["external_uri"]}"
#     EOH
#     creates metadata_file
#     cwd "/opt/data-transloader"
#     environment({
#       GEM_HOME: "#{tl_home}/.ruby",
#       GEM_PATH: "#{tl_home}/.ruby/gems",
#       PATH: "#{tl_home}/.ruby/bin:#{ENV["PATH"]}"
#     })
#     user tl_user
#   end
# end

########################
# Install Apache Airflow
########################

airflow_home = "/opt/airflow"
airflow_port = "5080"

package %w(python3-pip)

execute "Install airflow" do
  command "pip3 install apache-airflow"
end

directory airflow_home do
  recursive true
  action :create
end

# Directory for DAGs
directory "#{airflow_home}/dags" do
  recursive true
  action :create
end

template "#{airflow_home}/airflow.cfg" do
  source "airflow.cfg.erb"
  variables({
    airflow_home: airflow_home,
    fernet_key:   Base64.strict_encode64(SecureRandom.hex(16)),
    secret_key:   SecureRandom.hex
  })
  sensitive true
end

execute "Initialize airflow DB" do
  command "airflow initdb"
  env({
    "AIRFLOW_HOME" => airflow_home
  })
end

systemd_unit "airflow-webserver.service" do
  content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Airflow webserver daemon
    After=network.target

    [Service]
    Environment=AIRFLOW_HOME="#{airflow_home}"
    User=root
    Group=root
    Type=simple
    ExecStart=/usr/local/bin/airflow webserver --port #{airflow_port}
    Restart=on-failure
    RestartSec=5s
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end

systemd_unit "airflow-scheduler.service" do
  content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Airflow scheduler daemon
    After=network.target

    [Service]
    Environment=AIRFLOW_HOME="#{airflow_home}"
    User=root
    Group=root
    Type=simple
    ExecStart=/usr/local/bin/airflow scheduler
    Restart=always
    RestartSec=5s

    [Install]
    WantedBy=multi-user.target
  EOU

  action [:create, :enable, :start]
end

# Set up nginx virtual host for airflow
template "/etc/nginx/sites-available/airflow" do
  source "nginx/airflow.conf.erb"
  variables({
    port: airflow_port
  })
  notifies :reload, "service[nginx]"
end

link "/etc/nginx/sites-enabled/airflow" do
  to "/etc/nginx/sites-available/airflow"
  notifies :reload, "service[nginx]"
end

# Install Environment Canada ETL DAG
template "#{airflow_home}/dags/environment_canada_etl.py" do
  source "dags/basic_etl.py.erb"
  variables({
    dag_id: "environment_canada_etl",
    download_script: "sudo -u transloader -i #{tl_home}/ec-download",
    upload_script: "sudo -u transloader -i #{tl_home}/ec-upload",
    year: 2019,
    month: 8,
    day: 30,
    catchup: false
  })
  action :create
  notifies :restart, "systemd_unit[airflow-scheduler.service]"
end

# directory "/opt/etl" do
#   action :create
# end

# %w(etl-download etl-convert etl-upload).each do |file|
#   cookbook_file "/opt/etl/#{file}" do
#     source "#{file}.rb"
#     mode "755"
#     action :create
#   end
# end

########################
# Install Sensors Web UI
########################

include_recipe "nodejs::default"

directory node["dashboard"]["prefix"] do
  owner tl_user
  action :create
end

git node["dashboard"]["prefix"] do
  repository node["dashboard"]["repository"]
  user tl_user
end

execute "Install npm dependencies" do
  cwd node["dashboard"]["prefix"]
  user tl_user
  environment({ 
    HOME: tl_home,
    USER: tl_user
  })
  command "npm install"
end

# Customize URL for STA connection
template "#{node["dashboard"]["prefix"]}/config/environment.js" do
  source "sensorweb-env.js.erb"
  variables({
    sta_url: node["sensorthings"]["external_uri"]
  })
  owner tl_user
end

execute "Build site to static files" do
  cwd node["dashboard"]["prefix"]
  user tl_user
  environment({ 
    HOME: tl_home,
    USER: tl_user
  })
  command "node_modules/.bin/ember build --environment production"
end

# Set up nginx virtual host
template "/etc/nginx/sites-available/sensorweb" do
  source "nginx/sensorweb.conf.erb"
  variables({
    root: "#{node["dashboard"]["prefix"]}/dist"
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
