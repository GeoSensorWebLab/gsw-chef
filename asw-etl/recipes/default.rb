#
# Cookbook Name:: asw-etl
# Recipe:: default
#
# Copyright 2019–2020 GeoSensorWeb Lab, University of Calgary
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
require 'shellwords'
require 'time'
require 'uri'

apt_update

###############
# Install nginx
###############

package %w(nginx-full)

service "nginx" do
  supports [:start, :stop, :restart, :reload]
  action :nothing
end

# Remove default site
file "/etc/nginx/sites-enabled/default" do
  action :delete
end

##########################
# Install data transloader
##########################

tl_home = node["transloader"]["user_home"]
tl_user = node["transloader"]["user"]

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

directory node["transloader"]["install_home"] do
  owner tl_user
  recursive true
  action :create
end

git node["transloader"]["install_home"] do
  repository node["transloader"]["repository"]
  revision node["transloader"]["revision"]
  user tl_user
end

# Install Ruby
git "/opt/ruby-build" do
  repository "https://github.com/rbenv/ruby-build.git"
  reference node["ruby-build"]["reference"]
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
package %w(build-essential libssl-dev libreadline-dev zlib1g-dev)

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

bundler_version = node["ruby"]["bundler_version"]

bash "install transloader deps" do
  cwd node["transloader"]["install_home"]
  code <<-EOH
  gem install bundler:#{bundler_version}
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
cache_dir = node["etl"]["cache_dir"]

directory cache_dir do
  owner tl_user
  recursive true
  action :create
end

# Set up log directory
directory node["etl"]["log_dir"] do
  owner tl_user
  recursive true
  action :create
end

##############################
# Retrieve HTTP Basic Settings
##############################
# Read from Chef Vault (or Data Bag)
arctic_sensors_vault = chef_vault_item("secrets", node["transloader"]["etl_vault"])

basic_user     = nil
basic_password = nil
x_api_key      = arctic_sensors_vault["x-api-key"]

# If the ETL vault item doesn't exist, skip this next section.
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

# TODO: Update variable names for ETL v0.8 changes
template "#{ec_scripts_home}/download" do
  source "environment_canada/download.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir: cache_dir,
    log_dir:   node["etl"]["log_dir"],
    work_dir:  node["transloader"]["install_home"]
  })
end

# TODO: Update variable names for ETL v0.8 changes
template "#{ec_scripts_home}/upload" do
  source "environment_canada/upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    basic_user:     basic_user,
    basic_password: basic_password,
    cache_dir:      cache_dir,
    log_dir:        node["etl"]["log_dir"],
    sta_endpoint:   node["sensorthings"]["external_uri"],
    work_dir:       node["transloader"]["install_home"],
    x_api_key:      x_api_key
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

# TODO: Update variable names for ETL v0.8 changes
template "#{dg_scripts_home}/download" do
  source "data_garrison/download.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir: cache_dir,
    log_dir:   node["etl"]["log_dir"],
    work_dir:  node["transloader"]["install_home"]
  })
end

# TODO: Update variable names for ETL v0.8 changes
template "#{dg_scripts_home}/upload" do
  source "data_garrison/upload.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    basic_user:     basic_user,
    basic_password: basic_password,
    cache_dir:      cache_dir,
    log_dir:        node["etl"]["log_dir"],
    sta_endpoint:   node["sensorthings"]["external_uri"],
    work_dir:       node["transloader"]["install_home"],
    x_api_key:      x_api_key
  })
end

# TODO: Update variable names for ETL v0.8 changes
template "#{dg_scripts_home}/download-historical" do
  source "data_garrison/download-historical.sh.erb"
  owner tl_user
  mode "0755"
  variables({
    cache_dir:  cache_dir,
    log_dir:    node["etl"]["log_dir"],
    state_file: "#{dg_scripts_home}/historical-observations-downloaded",
    work_dir:   node["transloader"]["install_home"]
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

  # TODO: Update variable names for ETL v0.8 changes
  template "#{cs_scripts_home}/download_#{station_id}" do
    source "campbell_scientific/download.sh.erb"
    owner tl_user
    mode "0755"
    variables({
      blocked:   node["transloader"]["campbell_scientific_blocked"],
      cache_dir: cache_dir,
      log_dir:   node["etl"]["log_dir"],
      station:   station,
      work_dir:  node["transloader"]["install_home"]
    })
  end

  # TODO: Update variable names for ETL v0.8 changes
  template "#{cs_scripts_home}/upload_#{station_id}" do
    source "campbell_scientific/upload.sh.erb"
    owner tl_user
    mode "0755"
    variables({
      basic_user:     basic_user,
      basic_password: basic_password,
      blocked:        node["transloader"]["campbell_scientific_blocked"],
      cache_dir:      cache_dir,
      log_dir:        node["etl"]["log_dir"],
      sta_endpoint:   node["sensorthings"]["external_uri"],
      station:        station,
      work_dir:       node["transloader"]["install_home"],
      x_api_key:      x_api_key
    })
  end

  # TODO: Update variable names for ETL v0.8 changes
  template "#{cs_scripts_home}/download-historical_#{station_id}" do
    source "campbell_scientific/download-historical.sh.erb"
    owner tl_user
    mode "0755"
    variables({
      blocked:    node["transloader"]["campbell_scientific_blocked"],
      cache_dir:  cache_dir,
      log_dir:    node["etl"]["log_dir"],
      state_file: "#{cs_scripts_home}/historical-observations-downloaded",
      station:    station,
      work_dir:   node["transloader"]["install_home"]
    })
  end
end

# Set up log rotation
template "/etc/logrotate.d/auto-transload" do
  source "transloader-logrotate.erb"
  variables({
    logdir: node["etl"]["log_dir"],
    user: tl_user
  })
end

############################
# Run initial metadata fetch
############################

sensorthings_auth = ""

if !(basic_user.nil? || basic_user.empty?)
  sensorthings_auth += "--user '#{basic_user}:#{basic_password}'"
end

if !(x_api_key.nil? || x_api_key.empty?)
  sensorthings_auth += " --header 'X-Api-Key: #{x_api_key}'"
end

imported_stations = "#{node["transloader"]["user_home"]}/imported"

directory imported_stations do
  owner tl_user
  recursive true
  action :create
end

# ENVIRONMENT CANADA
ec_run_dir = "#{imported_stations}/environment_canada"

directory ec_run_dir do
  owner tl_user
  recursive true
  action :create
end

# We use the "creates" property to prevent re-running this resource
node["transloader"]["environment_canada_stations"].each do |stn|
  run_file = "#{ec_run_dir}/#{stn}"

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

        touch #{run_file}
    EOH
    creates run_file
    cwd node["transloader"]["install_home"]
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
dg_run_dir = "#{imported_stations}/data_garrison"

directory dg_run_dir do
  owner tl_user
  recursive true
  action :create
end

node["transloader"]["data_garrison_stations"].each do |stn|
  run_file = "#{dg_run_dir}/#{stn["user_id"]}-#{stn["station_id"]}"

  # TODO: Update variable names for ETL v0.8 changes
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
        --key "name" \
        --value "#{stn["name"]}"

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

      touch #{run_file}
    EOH
    creates run_file
    cwd node["transloader"]["install_home"]
    environment({
      GEM_HOME: "#{tl_home}/.ruby",
      GEM_PATH: "#{tl_home}/.ruby/gems",
      PATH: "#{tl_home}/.ruby/bin:#{ENV["PATH"]}"
    })
    user tl_user
  end
end

# CAMPBELL SCIENTIFIC
cs_run_dir = "#{imported_stations}/campbell_scientific"

directory cs_run_dir do
  owner tl_user
  recursive true
  action :create
end

node["transloader"]["campbell_scientific_stations"].each do |stn|
  run_file = "#{cs_run_dir}/#{stn["station_id"]}"

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

  # TODO: Update variable names for ETL v0.8 changes
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

      touch #{run_file}
    EOH
    creates run_file
    cwd node["transloader"]["install_home"]
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
airflow_vault = chef_vault_item("secrets", node["transloader"]["airflow_vault"])
airflow_home  = node["airflow"]["home"]
airflow_port  = "5080"

package %w(python3-pip)

execute "Install airflow" do
  command "pip3 install apache-airflow==#{node["airflow"]["version"]}"
end

execute "Install airflow postgresql support" do
  command "pip3 install 'apache-airflow[postgres]'==#{node["airflow"]["version"]}"
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

# Store Airflow logs on common logs path
airflow_logs_directory = node["etl"]["log_dir"] + "/airflow"
directory airflow_logs_directory do
  action :create
end

airflow_cfg = node["airflow"]

template "#{airflow_home}/airflow.cfg" do
  source "airflow.cfg.erb"
  variables({
    airflow_home:                airflow_home,
    base_url:                    airflow_cfg["base_url"],
    dags_are_paused_at_creation: airflow_cfg["dags_are_paused_at_creation"],
    dag_concurrency:             airflow_cfg["dag_concurrency"],
    executor:                    airflow_cfg["executor"],
    fernet_key:                  Base64.strict_encode64(SecureRandom.hex(16)),
    logs_directory:              airflow_logs_directory,
    max_active_runs_per_dag:     airflow_cfg["max_active_runs_per_dag"],
    parallelism:                 airflow_cfg["parallelism"],
    database_url:                airflow_vault["database_url"],
    secret_key:                  SecureRandom.hex
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

ht_file = nil

# If the airflow vault item doesn't exist, skip this next section.
if airflow_vault
  ht_file   = "#{airflow_home}/htpasswd"
  ht_user   = airflow_vault["username"]
  ht_passwd = Shellwords.escape(airflow_vault["password"])

  # Note that nginx does not support bcrypt passwords created by
  # Apache's htpasswd utility.
  execute "Create airflow http basic auth file" do
    command %Q[htpasswd -bcs #{ht_file} #{ht_user} #{ht_passwd}]
    creates ht_file
    sensitive true
  end

  # Run update even after create to make sure the latest username/password
  # exists in the file.
  execute "Update airflow http basic auth file" do
    command %Q[htpasswd -bs #{ht_file} #{ht_user} #{ht_passwd}]
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
    host:    URI(airflow_cfg["base_url"]).hostname,
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
      download_script:   "sudo -u transloader -i #{tl_home}/environment_canada/download #{station_id}",
      upload_script:     "sudo -u transloader -i #{tl_home}/environment_canada/upload #{station_id}",
      start_date:        now_date,
      catchup:           false
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
  end
end

# Install Data Garrison ETL DAG
node["transloader"]["data_garrison_stations"].each do |station|
  station_name    = station["name"].gsub(" ", "_")
  station_id      = station["station_id"]
  station_user_id = station["user_id"]

  template "#{airflow_home}/dags/data_garrison_etl_#{station_name}.py" do
    source "dags/long_etl.py.erb"
    variables({
      dag_id: "data_garrison_etl_#{station_name}",
      # Runs every hour at one minute past the hour.
      # Data Garrison weather stations log every 15 minutes, but only
      # upload every 120 minutes.
      schedule_interval: "1 * * * *",
      download_script:   "sudo -u transloader -i #{tl_home}/data_garrison/download #{station_id} #{station_user_id}",
      upload_script:     "sudo -u transloader -i #{tl_home}/data_garrison/upload #{station_id} #{station_user_id}",
      start_date:        now_date,
      catchup:           false
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
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
      download_script:   "sudo -u transloader -i #{tl_home}/data_garrison/download-historical #{station_id} #{station_user_id}",
      upload_script:     "sudo -u transloader -i #{tl_home}/data_garrison/upload #{station_id} #{station_user_id}",
      start_date:        historical_start_date,
      end_date:          now_date,
      catchup:           true
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
  end
end

# Install Campbell Scientific ETL DAG
node["transloader"]["campbell_scientific_stations"].each do |station|
  station_name = station["name"].gsub(" ", "_")
  station_id   = station["station_id"]

  template "#{airflow_home}/dags/campbell_scientific_etl_#{station_name}.py" do
    source "dags/basic_etl.py.erb"
    variables({
      dag_id: "campbell_scientific_etl_#{station_name}",
      # Runs every hour at one minute past the hour.
      schedule_interval: "1 * * * *",
      download_script:   "sudo -u transloader -i #{tl_home}/campbell_scientific/download_#{station_id}",
      upload_script:     "sudo -u transloader -i #{tl_home}/campbell_scientific/upload_#{station_id}",
      start_date:        now_date,
      catchup:           false
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
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
      download_script:   "sudo -u transloader -i #{tl_home}/campbell_scientific/download-historical_#{station_id}",
      upload_script:     "sudo -u transloader -i #{tl_home}/campbell_scientific/upload_#{station_id}",
      start_date:        historical_start_date,
      end_date:          now_date,
      catchup:           true
    })
    action :create
    notifies :restart, "systemd_unit[airflow-scheduler.service]"
  end
end

# Install DAG for deleting old Airflow log files
template "#{airflow_home}/dags/airflow-log-cleanup.py" do
  source "dags/airflow-log-cleanup.py"
  action :create
  notifies :restart, "systemd_unit[airflow-scheduler.service]"
end
