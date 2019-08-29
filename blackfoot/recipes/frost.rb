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


############################################
# 4. Start FROST server, and set up auto-run
############################################
