#
# Cookbook Name:: blackfoot
# Recipe:: frost
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
require 'securerandom'

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

service "docker" do
  action :nothing
end

###########################
# 2. Install docker-compose
###########################

remote_file "/usr/local/bin/docker-compose" do
  source "https://github.com/docker/compose/releases/download/#{node["docker_compose"]["version"]}/docker-compose-#{node["kernel"]["name"]}-#{node["kernel"]["processor"]}"
  owner "root"
  mode "0755"
  action :create
end

###########################
# 3. Clone FROST repository
###########################

directory "opt/frost" do
  owner "root"
  group "root"
  recursive true
  action :create
end

git "/opt/frost" do
  repository node["frost"]["repository"]
  depth 1
end

template "/opt/frost/docker-compose.yaml" do
  source "frost-compose.yaml"
  variables({
    service_root_url: "http://localhost:8080/FROST-Server",
    http_cors_enable: true,
    http_cors_allowed_origins: "*",
    # A random password can be used here, as only docker-compose needs
    # to know it
    persistence_db_password: SecureRandom.hex
  })
  sensitive true
end

#######################
# 4. Start FROST server
#######################

execute "start FROST" do
  command "docker-compose up -d"
  cwd "opt/frost"
  user "root"
end
