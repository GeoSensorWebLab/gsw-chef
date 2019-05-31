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
