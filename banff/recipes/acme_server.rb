#
# Cookbook Name:: banff
# Recipe:: acme_server
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

# Use Docker to start up a pebble container for testing ACME locally
docker_service 'default' do
  action [:create, :start]
end

docker_network 'acmenet' do
  subnet ['10.30.50.0/24']
end

directory '/opt/src/' do
  recursive true
  action :create
end
 
git '/opt/src/pebble' do
  repository node["pebble"]["repository"]
  reference node["pebble"]["version"]
end

dockerfile_path = ""

# The path to the Dockerfile is different for v1/v2
if node["pebble"]["version"].match?(/^v1.+/)
  dockerfile_path = "docker/pebble/Dockerfile"
elsif node["pebble"]["version"].match?(/^v2.+/)
  dockerfile_path = "docker/pebble/linux.Dockerfile"
else
  log 'unknown pebble version' do
    level :warn
  end
  dockerfile_path = "docker/pebble/linux.Dockerfile"
end

# Because the Dockerfile uses COPY, we can't use docker_image!
bash 'build pebble image' do
  code <<-EOH
  docker build --tag pebble:#{node["pebble"]["version"]} --file #{dockerfile_path} .
  EOH
  cwd '/opt/src/pebble'
end

docker_container 'pebble' do
  repo 'pebble'
  tag node["pebble"]["version"]
  # HTTPS ACME API
  port ['14000:14000']
  network_mode 'acmenet'
  ip_address '10.30.50.2'
  env ['PEBBLE_VA_NOSLEEP=1', 'PEBBLE_VA_ALWAYS_VALID=1', 'PEBBLE_WFE_NONCEREJECT=0']
  command 'pebble -config /test/config/pebble-config.json -strict true'
end
