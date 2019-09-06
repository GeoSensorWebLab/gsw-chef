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
  repository node["transloader"]["repository"]
  revision node["transloader"]["revision"]
  user tl_user
end

# Install Ruby
git "/opt/ruby-build" do
  repository "https://github.com/rbenv/ruby-build.git"
end

execute "Install ruby-build" do
  command "./install.sh"
  cwd "/opt/ruby-build"
  environment({
    PREFIX: "/usr/local"
  })
  creates "/usr/local/bin/ruby-build"
end

# Install Ruby dependencies
package %w(autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev)

ruby_version = node["ruby"]["version"]

execute "Install Ruby #{ruby_version}" do
  command "ruby-build #{ruby_version} /opt/ruby/#{ruby_version}"
  creates "/opt/ruby/#{ruby_version}"
end

bash "Link Ruby" do
  cwd "/opt/ruby/#{ruby_version}/bin/"
  code <<-EOH
  for FILE in *; do
    ln -sf /opt/ruby/#{ruby_version}/bin/$FILE /usr/local/bin/$FILE
  done
  EOH
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

############################
# Environment Canada Scripts
############################

ec_scripts_home = "#{tl_home}/environment_canada"

directory ec_scripts_home do
  owner tl_user
  recursive true
end

template "#{ec_scripts_home}/download" do
  source "environment_canada/download.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir: cache_dir,
    log_dir:   "/srv/logs",
    stations:  node["transloader"]["environment_canada_stations"],
    work_dir:  "/opt/data-transloader"
  })
end

template "#{ec_scripts_home}/upload" do
  source "environment_canada/upload.sh.erb"
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

#######################
# Data Garrison Scripts
#######################

dg_scripts_home = "#{tl_home}/data_garrison"

directory dg_scripts_home do
  owner tl_user
  recursive true
end

template "#{dg_scripts_home}/download" do
  source "data_garrison/download.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir: cache_dir,
    log_dir:   "/srv/logs",
    stations:  node["transloader"]["data_garrison_stations"],
    work_dir:  "/opt/data-transloader"
  })
end

template "#{dg_scripts_home}/upload" do
  source "data_garrison/upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir:    cache_dir,
    log_dir:      "/srv/logs",
    sta_endpoint: node["sensorthings"]["external_uri"],
    stations:     node["transloader"]["data_garrison_stations"],
    work_dir:     "/opt/data-transloader"
  })
end

#############################
# Campbell Scientific Scripts
#############################

cs_scripts_home = "#{tl_home}/campbell_scientific"

directory cs_scripts_home do
  owner tl_user
  recursive true
end

template "#{cs_scripts_home}/download" do
  source "campbell_scientific/download.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    blocked:   node["transloader"]["campbell_scientific_blocked"],
    cache_dir: cache_dir,
    log_dir:   "/srv/logs",
    stations:  node["transloader"]["campbell_scientific_stations"],
    work_dir:  "/opt/data-transloader"
  })
end

template "#{cs_scripts_home}/upload" do
  source "campbell_scientific/upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    blocked:      node["transloader"]["campbell_scientific_blocked"],
    cache_dir:    cache_dir,
    log_dir:      "/srv/logs",
    sta_endpoint: node["sensorthings"]["external_uri"],
    stations:     node["transloader"]["campbell_scientific_stations"],
    work_dir:     "/opt/data-transloader"
  })
end

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
node["transloader"]["data_garrison_stations"].each do |stn|
  metadata_file = "#{cache_dir}/data_garrison/metadata/#{stn["user_id"]}-#{stn["station_id"]}.json"
  
  bash "import Data Garrison station #{stn["station_id"]} metadata" do
    code <<-EOH
      set -e
      
      ruby transload get metadata \
        --provider data_garrison \
        --user_id #{stn["user_id"]} \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}"

      ruby transload set metadata \
        --provider data_garrison \
        --user_id #{stn["user_id"]} \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --key "latitude" \
        --value "#{stn["latitude"]}"

        ruby transload set metadata \
        --provider data_garrison \
        --user_id #{stn["user_id"]} \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --key "longitude" \
        --value "#{stn["longitude"]}"

        ruby transload set metadata \
        --provider data_garrison \
        --user_id #{stn["user_id"]} \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --key "timezone_offset" \
        --value "#{stn["timezone_offset"]}"

      ruby transload put metadata \
        --provider data_garrison \
        --user_id #{stn["user_id"]} \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --destination "#{node["sensorthings"]["external_uri"]}"
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

# CAMPBELL SCIENTIFIC
node["transloader"]["campbell_scientific_stations"].each do |stn|
  metadata_file = "#{cache_dir}/campbell_scientific/metadata/#{stn["station_id"]}.json"

  data_urls_arg = stn["data_files"].reduce("") do |memo, url|
    memo += "--data_url #{url} "
    memo
  end
  
  bash "import Campbell Scientific station #{stn["station_id"]} metadata" do
    code <<-EOH
      set -e
      
      ruby transload get metadata \
        --provider campbell_scientific \
        --station_id #{stn["station_id"]} \
        #{data_urls_arg} \
        --cache "#{cache_dir}"

      ruby transload set metadata \
        --provider campbell_scientific \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --key "latitude" \
        --value "#{stn["latitude"]}"

        ruby transload set metadata \
        --provider campbell_scientific \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --key "longitude" \
        --value "#{stn["longitude"]}"

        ruby transload set metadata \
        --provider campbell_scientific \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --key "timezone_offset" \
        --value "#{stn["timezone_offset"]}"

      ruby transload put metadata \
        --provider campbell_scientific \
        --station_id #{stn["station_id"]} \
        --cache "#{cache_dir}" \
        --destination "#{node["sensorthings"]["external_uri"]}" \
        --blocked #{node["transloader"]["campbell_scientific_blocked"]}
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
    # Runs every hour at one minute past the hour
    schedule_interval: "1 * * * *",
    download_script: "sudo -u transloader -i #{tl_home}/environment_canada/download",
    upload_script: "sudo -u transloader -i #{tl_home}/environment_canada/upload",
    start_date: {
      year: 2019,
      month: 8,
      day: 30
    },
    catchup: false
  })
  action :create
  notifies :restart, "systemd_unit[airflow-scheduler.service]"
end

# Install Data Garrison ETL DAG
template "#{airflow_home}/dags/data_garrison_etl.py" do
  source "dags/basic_etl.py.erb"
  variables({
    dag_id: "data_garrison_etl",
    # Runs every hour at one minute past the hour.
    # Data Garrison weather stations log every 15 minutes, but only 
    # upload every 120 minutes. We run every hour to be more likely to
    # catch "fresh" data.
    schedule_interval: "1 * * * *",
    download_script: "sudo -u transloader -i #{tl_home}/data_garrison/download",
    upload_script: "sudo -u transloader -i #{tl_home}/data_garrison/upload",
    start_date: {
      year: 2019,
      month: 8,
      day: 30
    },
    catchup: false
  })
  action :create
  notifies :restart, "systemd_unit[airflow-scheduler.service]"
end

# Install Campbell Scientific ETL DAG
template "#{airflow_home}/dags/campbell_scientific_etl.py" do
  source "dags/basic_etl.py.erb"
  variables({
    dag_id: "campbell_scientific_etl",
    # Runs every hour at one minute past the hour.
    schedule_interval: "1 * * * *",
    download_script: "sudo -u transloader -i #{tl_home}/campbell_scientific/download",
    upload_script: "sudo -u transloader -i #{tl_home}/campbell_scientific/upload",
    start_date: {
      year: 2019,
      month: 8,
      day: 30
    },
    catchup: false
  })
  action :create
  notifies :restart, "systemd_unit[airflow-scheduler.service]"
end

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
