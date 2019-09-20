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
require 'time'

apt_update

###############
# Install nginx
###############

package %w(nginx-full)

service "nginx" do
  supports [:start, :stop, :restart, :reload]
  action :nothing
end

####################
# Install PostgreSQL
####################
postgresql_server_install "PostgreSQL for Airflow" do
  version node["postgresql"]["version"]
  action :install
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

##############################
# Retrieve HTTP Basic Settings
##############################
# Read from Chef Vault (or Data Bag)
arctic_sensors_vault = chef_vault_item("secrets", "arctic_sensors")

basic_user     = nil
basic_password = nil

# If the airflow vault item doesn't exist, skip this next section.
if arctic_sensors_vault && arctic_sensors_vault["http_basic_enabled"]
  basic_user     = arctic_sensors_vault["username"]
  basic_password = arctic_sensors_vault["password"]
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
    work_dir:  "/opt/data-transloader"
  })
end

template "#{ec_scripts_home}/upload" do
  source "environment_canada/upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    basic_user:     basic_user,
    basic_password: basic_password,
    cache_dir:      cache_dir,
    log_dir:        "/srv/logs",
    sta_endpoint:   node["sensorthings"]["external_uri"],
    work_dir:       "/opt/data-transloader"
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
    work_dir:  "/opt/data-transloader"
  })
end

template "#{dg_scripts_home}/upload" do
  source "data_garrison/upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    basic_user:     basic_user,
    basic_password: basic_password,
    cache_dir:      cache_dir,
    log_dir:        "/srv/logs",
    sta_endpoint:   node["sensorthings"]["external_uri"],
    work_dir:       "/opt/data-transloader"
  })
end

template "#{dg_scripts_home}/download-historical" do
  source "data_garrison/download-historical.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir:  cache_dir,
    log_dir:    "/srv/logs",
    state_file: "#{dg_scripts_home}/historical-observations-downloaded",
    work_dir:   "/opt/data-transloader"
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

node["transloader"]["campbell_scientific_stations"].each do |station|
  station_id = station["station_id"]

  template "#{cs_scripts_home}/download_#{station_id}" do
    source "campbell_scientific/download.sh.erb"
    owner tl_user
    mode "0755"
    variables({
      blocked:   node["transloader"]["campbell_scientific_blocked"],
      cache_dir: cache_dir,
      log_dir:   "/srv/logs",
      station:   station,
      work_dir:  "/opt/data-transloader"
    })
  end

  template "#{cs_scripts_home}/upload_#{station_id}" do
    source "campbell_scientific/upload.sh.erb"
    owner tl_user
    mode "0755"
    variables({
      basic_user:     basic_user,
      basic_password: basic_password,
      blocked:        node["transloader"]["campbell_scientific_blocked"],
      cache_dir:      cache_dir,
      log_dir:        "/srv/logs",
      sta_endpoint:   node["sensorthings"]["external_uri"],
      station:        station,
      work_dir:       "/opt/data-transloader"
    })
  end

  template "#{cs_scripts_home}/download-historical_#{station_id}" do
    source "campbell_scientific/download-historical.sh.erb"
    owner tl_user
    mode "0755"
    variables({
      blocked:    node["transloader"]["campbell_scientific_blocked"],
      cache_dir:  cache_dir,
      log_dir:    "/srv/logs",
      state_file: "#{cs_scripts_home}/historical-observations-downloaded",
      station:    station,
      work_dir:   "/opt/data-transloader"
    })
  end
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

if basic_user.nil? || basic_user.empty?
  sensorthings_auth = ""
else
  sensorthings_auth = "--user '#{basic_user}:#{basic_password}'"
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
    # Some stations may have missing SWOB-ML files occasionally —
    # the reason is currently unknown. When that happens this step would
    # normally fail for that specific station, so we ignore it.
    ignore_failure true
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
        --destination "#{node["sensorthings"]["external_uri"]}" \
        #{sensorthings_auth}
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

  # Convert data URLs to arguments
  data_urls_arg = stn["data_files"].reduce("") do |memo, url|
    memo += "--data_url #{url} "
    memo
  end

  # Convert archive data URLs to arguments
  # These are necessary to be configured in the metadata before
  # historical data uploads can work
  archive_data_urls_arg = stn["archive_data_files"].reduce("") do |memo, url|
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
        #{archive_data_urls_arg} \
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
        --blocked #{node["transloader"]["campbell_scientific_blocked"]} \
        #{sensorthings_auth}
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

#############################
# Set up Database for Airflow
#############################

pg_airflow_user = "airflow"
pg_airflow_pass = SecureRandom.hex(16)
pg_airflow_db   = "airflow"

postgresql_user pg_airflow_user do
  password pg_airflow_pass
  createdb true
  sensitive true
  action [:create, :update]
end

postgresql_database pg_airflow_db do
  owner pg_airflow_user
end

postgresql_access "local_airflow" do
  comment "Local airflow access"
  access_type "local"
  access_db pg_airflow_db
  access_user pg_airflow_user
  access_addr nil
  access_method "md5"
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

execute "Install airflow postgresql support" do
  command "pip3 install 'apache-airflow[postgres]'"
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

  action :create
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

  action :create
end

template "#{airflow_home}/airflow.cfg" do
  source "airflow.cfg.erb"
  variables({
    airflow_home: airflow_home,
    fernet_key:   Base64.strict_encode64(SecureRandom.hex(16)),
    pg_connection: "#{pg_airflow_user}:#{pg_airflow_pass}@localhost:5432/#{pg_airflow_db}",
    secret_key:   SecureRandom.hex
  })
  sensitive true
  # Restart the Airflow applications when the configuration changes
  notifies :restart, "systemd_unit[airflow-webserver.service]"
  notifies :restart, "systemd_unit[airflow-scheduler.service]"
end

execute "Initialize airflow DB" do
  command "airflow initdb"
  env({
    "AIRFLOW_HOME" => airflow_home
  })
end

systemd_unit "airflow-webserver.service" do
  action [:enable, :start]
end

systemd_unit "airflow-scheduler.service" do
  action [:enable, :start]
end

# Create htpassword for Airflow HTTP Basic authentication
package %w(apache2-utils)

ht_file       = nil
airflow_vault = chef_vault_item("secrets", "airflow")

# If the airflow vault item doesn't exist, skip this next section.
if airflow_vault
  ht_file   = "/opt/airflow/htpasswd"
  ht_user   = airflow_vault["username"]
  ht_passwd = airflow_vault["password"]

  # Note that nginx does not support bcrypt passwords created by 
  # Apache's htpasswd utility.
  execute "Create airflow http basic auth file" do
    command %Q[htpasswd -bcs #{ht_file} #{ht_user} "#{ht_passwd}"]
    creates ht_file
    sensitive true
  end

  # Run update even after create to make sure the latest username/password
  # exists in the file.
  execute "Update airflow http basic auth file" do
    command %Q[htpasswd -bs #{ht_file} #{ht_user} "#{ht_passwd}"]
    sensitive true
  end

  file ht_file do
    mode "400"
    owner "www-data"
  end
end

# Set up nginx virtual host for airflow
template "/etc/nginx/sites-available/airflow" do
  source "nginx/airflow.conf.erb"
  variables({
    ht_file: ht_file,
    port:    airflow_port
  })
  notifies :reload, "service[nginx]"
end

link "/etc/nginx/sites-enabled/airflow" do
  to "/etc/nginx/sites-available/airflow"
  notifies :reload, "service[nginx]"
end

##########################
# Install DAGs for Airflow
##########################
# Historical ETL start date
historical_start_date = {
  year:  node["etl"]["year"],
  month: node["etl"]["month"],
  day:   node["etl"]["day"]
}

# Current End Date
now = Time.now
now_date = {
  year:  now.year,
  month: now.month,
  day:   now.day
}

# Install Environment Canada ETL DAGs
node["transloader"]["environment_canada_stations"].each do |station_id|
  template "#{airflow_home}/dags/environment_canada_etl_#{station_id}.py" do
    source "dags/basic_etl.py.erb"
    variables({
      dag_id: "environment_canada_etl_#{station_id}",
      # Runs every hour at one minute past the hour
      schedule_interval: "1 * * * *",
      download_script: "sudo -u transloader -i #{tl_home}/environment_canada/download #{station_id}",
      upload_script: "sudo -u transloader -i #{tl_home}/environment_canada/upload #{station_id}",
      start_date: now_date,
      catchup: false
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
    only_if { ::File.exists?("#{cache_dir}/environment_canada/metadata/#{station_id}.json") }
  end
end

# Install Data Garrison ETL DAG
node["transloader"]["data_garrison_stations"].each do |station|
  station_name    = station["name"].gsub(" ", "_")
  station_id      = station["station_id"]
  station_user_id = station["user_id"]

  template "#{airflow_home}/dags/data_garrison_etl_#{station_name}.py" do
    source "dags/basic_etl.py.erb"
    variables({
      dag_id: "data_garrison_etl_#{station_name}",
      # Runs every hour at one minute past the hour.
      # Data Garrison weather stations log every 15 minutes, but only 
      # upload every 120 minutes. We run every hour to be more likely to
      # catch "fresh" data.
      schedule_interval: "1 * * * *",
      download_script: "sudo -u transloader -i #{tl_home}/data_garrison/download #{station_id} #{station_user_id}",
      upload_script: "sudo -u transloader -i #{tl_home}/data_garrison/upload #{station_id} #{station_user_id}",
      start_date: now_date,
      catchup: false
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
    only_if { ::File.exists?("#{cache_dir}/data_garrison/metadata/#{station_user_id}-#{station_id}.json") }
  end

  # Install Data Garrison Historical ETL DAG
  template "#{airflow_home}/dags/data_garrison_historical_etl_#{station_name}.py" do
    source "dags/historical_etl.py.erb"
    variables({
      dag_id: "data_garrison_historical_etl_#{station_name}",
      # Runs historical imports one day at a time at 00:00. This is
      # automatically interpreted as a 24-hour interval, which will be
      # passed to the data transloader.
      schedule_interval: "0 0 * * *",
      download_script: "sudo -u transloader -i #{tl_home}/data_garrison/download-historical #{station_id} #{station_user_id}",
      upload_script: "sudo -u transloader -i #{tl_home}/data_garrison/upload #{station_id} #{station_user_id}",
      start_date: historical_start_date,
      end_date: now_date,
      catchup: true
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
    only_if { ::File.exists?("#{cache_dir}/data_garrison/metadata/#{station_user_id}-#{station_id}.json") }
  end
end

# Install Campbell Scientific ETL DAG
node["transloader"]["data_garrison_stations"].each do |station|
  station_name = station["name"].gsub(" ", "_")
  station_id   = station["station_id"]

  template "#{airflow_home}/dags/campbell_scientific_etl_#{station_name}.py" do
    source "dags/basic_etl.py.erb"
    variables({
      dag_id: "campbell_scientific_etl_#{station_name}",
      # Runs every hour at one minute past the hour.
      schedule_interval: "1 * * * *",
      download_script: "sudo -u transloader -i #{tl_home}/campbell_scientific/download_#{station_id}",
      upload_script: "sudo -u transloader -i #{tl_home}/campbell_scientific/upload_#{station_id}",
      start_date: now_date,
      catchup: false
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
    only_if { ::File.exists?("#{cache_dir}/campbell_scientific/metadata/#{station_id}.json") }
  end

  # Install Campbell Scientific Historical ETL DAG
  template "#{airflow_home}/dags/campbell_scientific_historical_etl_#{station_name}.py" do
    source "dags/historical_etl.py.erb"
    variables({
      dag_id: "campbell_scientific_historical_etl_#{station_name}",
      # Runs historical imports one day at a time at 00:00. This is
      # automatically interpreted as a 24-hour interval, which will be
      # passed to the data transloader.
      schedule_interval: "0 0 * * *",
      download_script: "sudo -u transloader -i #{tl_home}/campbell_scientific/download-historical_#{station_id}",
      upload_script: "sudo -u transloader -i #{tl_home}/campbell_scientific/upload_#{station_id}",
      start_date: historical_start_date,
      end_date: now_date,
      catchup: true
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
    only_if { ::File.exists?("#{cache_dir}/campbell_scientific/metadata/#{station_id}.json") }
  end
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
