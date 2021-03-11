#
# Cookbook Name:: beddington
# Recipe:: default
#
# Copyright 2021 GeoSensorWeb Lab, University of Calgary
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
require 'date'

apt_update

#####
# ZFS
#####

# If the zpool does not exist, then this will have a non-zero exit code.
# See the README for manual preconfiguration instructions.
pool_name = "storage"
bash "check for '#{pool_name}' zpool" do
  code <<-EOH
  /usr/sbin/zpool status #{pool_name}
  EOH
end

# If the pool is available, next we create the filesystems.
bash "create zfs filesystem for backups" do
  code <<-EOH
  /usr/sbin/zfs create #{pool_name}/backups
  EOH
  not_if "/usr/sbin/zfs list #{pool_name}/backups"
end

bash "create zfs filesystem for wiki configuration" do
  code <<-EOH
  /usr/sbin/zfs create #{pool_name}/config
  EOH
  not_if "/usr/sbin/zfs list #{pool_name}/config"
end

bash "create zfs filesystem for docker" do
  code <<-EOH
  /usr/sbin/zfs create #{pool_name}/docker
  EOH
  not_if "/usr/sbin/zfs list #{pool_name}/docker"
end

bash "set zfs quota for docker" do
  code <<-EOH
  /usr/sbin/zfs set quota=#{node["beddington"]["docker_quota"]} #{pool_name}/docker
  EOH
end

########
# Docker
########

# Set up Docker using 'docker' cookbook resources
docker_service "default" do
  action [:create, :start]
end

# Install Docker Compose
remote_file "/usr/local/bin/docker-compose" do
  source "https://github.com/docker/compose/releases/download/#{node["docker_compose"]["version"]}/docker-compose-#{node["docker_compose"]["os"]}-#{node["docker_compose"]["arch"]}"
  checksum node["docker_compose"]["sha256"]
  mode "0755"
  owner "root"
  group "root"
end

# Switch to ZFS storage driver for Docker
cookbook_file "/etc/docker/daemon.json" do
  source "docker-daemon.json"
  notifies :restart, "docker_service[default]", :immediately
end

##################
# DokuWiki Install
##################

# Install docker-compose file for DokuWiki
default_user = node["beddington"]["user"]
directory "/home/#{default_user}/dokuwiki" do
  action :create
  recursive true
end

compose_yaml = "/home/#{default_user}/dokuwiki/docker-compose.yaml"
cookbook_file compose_yaml do
  source "dokuwiki.yaml"
  owner default_user
  group default_user
end

execute "create dokuwiki containers" do
  command "docker-compose up --no-start"
  cwd "/home/#{default_user}/dokuwiki"
  user "root"
end

service "dokuwiki" do
  restart_command "docker-compose --file #{compose_yaml} --project-name dokuwiki restart"
  start_command "docker-compose --file #{compose_yaml} --project-name dokuwiki start"
  stop_command "docker-compose --file #{compose_yaml} --project-name dokuwiki stop"
  user "root"
  action :start
end

dokuwiki_config = "/storage/config/dokuwiki/conf"

# Modify allowed MIME types for file uploads. This permits CSV files.
cookbook_file "#{dokuwiki_config}/mime.local.conf" do
  source "mime.local.conf"
  owner default_user
  group default_user
  notifies :restart, "service[dokuwiki]"
end

#################
# DokuWiki Config
#################
# This next section replaces the usage of the "install.php" browser
# wizard. It does this by re-creating the PHP script via Chef resources.
# Changes/updates to any of these files will queue a restart of
# DokuWiki.
#
# These files are only written by Chef once, as subsequent runs may
# overwrite changes to these files made by the administration interface
# in DokuWiki.
#
# Install script for reference:
# https://github.com/splitbrain/dokuwiki/blob/master/install.php

# Load SMTP authentication from Chef Vault
dokuwiki_vault = chef_vault_item("secrets", "dokuwiki")

smtp_auth_user = nil
smtp_auth_pass = nil

if dokuwiki_vault
  smtp_auth_user = dokuwiki_vault["smtp_auth_user"]
  smtp_auth_pass = dokuwiki_vault["smtp_auth_pass"]
end

# Create local.php
template "#{dokuwiki_config}/local.php" do
  source "local.php.erb"
  variables({
    auth_pass:   smtp_auth_pass,
    auth_user:   smtp_auth_user,
    date:        DateTime.now.to_s,
    license:     node["dokuwiki"]["license"],
    localdomain: node["dokuwiki"]["localdomain"],
    mailfrom:    node["dokuwiki"]["mailfrom"],
    smtp_host:   node["dokuwiki"]["smtp_host"],
    smtp_port:   node["dokuwiki"]["smtp_port"],
    smtp_ssl:    node["dokuwiki"]["smtp_ssl"],
    title:       node["dokuwiki"]["title"],
    user:        default_user
  })
  sensitive true
  owner default_user
  group default_user
  # important: do not overwrite existing file, as this file is also
  # modified by DokuWiki admin UI
  action :create_if_missing
  notifies :restart, "service[dokuwiki]"
end

dokuwiki_users = []

if dokuwiki_vault
  dokuwiki_users = dokuwiki_vault["users"]
end

# Create users.auth.php
template "#{dokuwiki_config}/users.auth.php" do
  source "users.auth.php.erb"
  variables({
    date:  DateTime.now.to_s,
    users: dokuwiki_users
  })
  sensitive true
  owner default_user
  group default_user
  # important: do not overwrite existing file, as this file is also
  # modified by DokuWiki admin UI
  action :create_if_missing
  notifies :restart, "service[dokuwiki]"
end

# Create acl.auth.php (groups and permissions)
template "#{dokuwiki_config}/acl.auth.php" do
  source "acl.auth.php.erb"
  variables({
    date:  DateTime.now.to_s
  })
  owner default_user
  group default_user
  # important: do not overwrite existing file, as this file is also
  # modified by DokuWiki admin UI
  action :create_if_missing
  notifies :restart, "service[dokuwiki]"
end

# Create plugins.local.php
template "#{dokuwiki_config}/plugins.local.php" do
  source "plugins.local.php.erb"
  owner default_user
  group default_user
  # important: do not overwrite existing file, as this file is also
  # modified by DokuWiki admin UI
  action :create_if_missing
  notifies :restart, "service[dokuwiki]"
end

# Install plugins for DokuWiki
# These are defined in the attributes
plugins_dir = "/storage/config/dokuwiki/lib/plugins"

node["dokuwiki"]["plugins"].each do |plugin|
  archive_file = "#{Chef::Config["file_cache_path"]}/#{plugin["base"]}.tar.gz"
  extract_path = "#{plugins_dir}/#{plugin["base"]}"

  remote_file archive_file do
    source plugin["source"]
  end

  bash "extract #{plugin["base"]} plugin" do
    cwd Chef::Config["file_cache_path"]
    code <<-EOH
    mkdir -p #{extract_path}
    tar xzf #{archive_file} -C #{extract_path}
    mv #{extract_path}/*/* #{extract_path}/
    EOH
    notifies :restart, "service[dokuwiki]"
    not_if { ::File.exist?(extract_path) }
  end
end

################
# Restic Backups
################
restic_url   = node["restic"]["source"]
archive_file = "#{Chef::Config["file_cache_path"]}/#{::File.basename(restic_url)}"
restic_bin   = "/usr/local/bin/restic"

remote_file archive_file do
  source restic_url
end

bash "extract restic" do
  cwd Chef::Config["file_cache_path"]
  code <<-EOH
  bzcat --keep #{archive_file} > #{restic_bin}
  chmod 0755 #{restic_bin}
  EOH
  not_if { ::File.exist?(restic_bin) }
end

# Load restic configuration from Chef Vault.
# It is not enabled in testing (test-kitchen) as I don't want to upload
# test data to S3.
beddington_vault = chef_vault_item("secrets", "beddington")

if beddington_vault && beddington_vault["restic_enabled"]
  init_lockfile = "/home/#{default_user}/restic_initialized"

  bash "initialize restic repository" do
    code <<-EOH
    restic init && touch #{init_lockfile}
    EOH
    cwd "/home/#{default_user}"
    environment({
      AWS_ACCESS_KEY_ID:     beddington_vault["AWS_ACCESS_KEY_ID"],
      AWS_SECRET_ACCESS_KEY: beddington_vault["AWS_SECRET_ACCESS_KEY"],
      AWS_DEFAULT_REGION:    beddington_vault["AWS_DEFAULT_REGION"],
      RESTIC_PASSWORD:       beddington_vault["RESTIC_PASSWORD"],
      RESTIC_REPOSITORY:     beddington_vault["RESTIC_REPOSITORY"]
    })
    user default_user
    not_if { ::File.exist?(init_lockfile) }
  end

  template "/usr/local/sbin/wiki-backup" do
    source "wiki-backup.sh.erb"
    variables({
      snapshot_name: "storage/config@restic-backup",
      snapshot_path: "/storage/config/.zfs/snapshot/restic-backup"
    })
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/cron.d/wiki-backup" do
    source "wiki-backup.cron.erb"
    variables({
      AWS_ACCESS_KEY_ID:     beddington_vault["AWS_ACCESS_KEY_ID"],
      AWS_SECRET_ACCESS_KEY: beddington_vault["AWS_SECRET_ACCESS_KEY"],
      AWS_DEFAULT_REGION:    beddington_vault["AWS_DEFAULT_REGION"],
      RESTIC_PASSWORD:       beddington_vault["RESTIC_PASSWORD"],
      RESTIC_REPOSITORY:     beddington_vault["RESTIC_REPOSITORY"]
    })
    owner "root"
    group "root"
    mode "0755"
  end
end

#####################
# Static HTML Backups
#####################

if beddington_vault && beddington_vault["html_backup_enabled"]
  cookbook_file "/usr/local/bin/offline_wiki.sh" do
    source "offline_dokuwiki.sh"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/usr/local/sbin/wiki-backup-html" do
    source "wiki-backup-html.sh.erb"
    variables({
      archive_file: "/storage/backups/htmlexport.tgz",
      backup_dir:   "/storage/backups/wiki_data",
      hostname:     "internal.arcticconnect.ca",
      S3_key:       beddington_vault["html_backup_s3_key"]
    })
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/cron.d/wiki-backup-html" do
    source "wiki-backup-html.cron.erb"
    variables({
      AWS_ACCESS_KEY_ID:     beddington_vault["AWS_ACCESS_KEY_ID"],
      AWS_SECRET_ACCESS_KEY: beddington_vault["AWS_SECRET_ACCESS_KEY"],
      AWS_DEFAULT_REGION:    beddington_vault["AWS_DEFAULT_REGION"],
      WIKI_USER:             beddington_vault["wiki_user"],
      WIKI_PASSWORD:         beddington_vault["wiki_password"]
    })
    owner "root"
    group "root"
    mode "0755"
  end
end
