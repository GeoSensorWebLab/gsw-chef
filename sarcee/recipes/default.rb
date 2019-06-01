#
# Cookbook Name:: sarcee
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


# Apply custom Apt proxies, if necessary
template "/etc/apt/apt.conf.d/01proxy" do
  source "01proxy.erb"
  variables(
    http:         node["apt"]["http_proxies"],
    http_direct:  node["apt"]["http_direct"],
    https:        node["apt"]["https_proxies"],
    https_direct: node["apt"]["https_direct"],
    ftp:          node["apt"]["ftp_proxies"],
    ftp_direct:   node["apt"]["ftp_direct"]
  )
end

###################
# 1. Install Docker
###################

apt_update

package %w(apt-transport-https ca-certificates curl gnupg-agent software-properties-common)


apt_repository "docker" do
  arch "amd64"
  components ["stable"]
  key "https://download.docker.com/linux/ubuntu/gpg"
  uri "https://download.docker.com/linux/ubuntu"
end

apt_update

package %w(docker-ce docker-ce-cli containerd.io)

##################
# 2. Install Dokku
##################

apt_repository "dokku" do
  components ["main"]
  key "https://packagecloud.io/dokku/dokku/gpgkey"
  uri "https://packagecloud.io/dokku/dokku/ubuntu/"
end

apt_update

package %w(dokku)

execute "install dokku core plugins" do
  command "dokku plugin:install-dependencies --core"
end

#####################
# 3. EOL Static Sites
#####################

directory "/var/www/eol-sites" do
  recursive true
  action :create
end

eol_sites_tempdir = "#{Chef::Config[:file_cache_path]}/eol-sites"

git eol_sites_tempdir do
  repository node["sarcee"]["eol_sites_repository"]
end

# Add public keys of people we trust to sign commits
node["gpg"]["import_keys"].each do |key_url|
  execute "import gpg key" do
    command "curl #{key_url} | gpg --import"
  end
end

# Only sync if latest commit is signed with GPG.
# This is done as we are loading nginx configuration from a public
# repository automatically.
execute "check for signed commit" do
  command "git verify-commit HEAD"
  cwd eol_sites_tempdir
end

execute "rsync EOL sites updates" do
  command "rsync -ah --delete #{eol_sites_tempdir}/conf #{eol_sites_tempdir}/sites /var/www/eol-sites/."
end

cookbook_file "/etc/nginx/conf.d/eol-sites.conf" do
  source "eol-sites.conf"
end

service "nginx" do
  action :reload
end

######################
# 4. Create Dokku Apps
######################

node["dokku"]["apps"].each do |app|
  execute "create app for #{app[:name]}" do
    command "dokku apps:create #{app[:name]}"
    not_if "dokku apps:exists #{app[:name]}"
  end

  execute "set domains for #{app[:name]}" do
    command "dokku domains:set #{app[:name]} #{app[:domains].join(" ")}"
  end
end
