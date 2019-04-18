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

docker_network 'acme' do
end

directory '/opt/src/' do
  recursive true
  action :create
end
 
git '/opt/src/pebble' do
  repository 'https://github.com/letsencrypt/pebble'
  reference 'v2.0.2'
end

# docker_image 'pebble' do
#   tag 'v2.0.2'
#   source '/opt/src/pebble/docker/pebble/linux.Dockerfile'
#   action :build
# end

# Because the Dockerfile uses COPY, we can't use docker_image!
bash 'build pebble image' do
  code <<-EOH
  docker build --tag pebble:v2.0.2 --file docker/pebble/linux.Dockerfile .
  EOH
  cwd '/opt/src/pebble'

end

docker_container 'pebble' do
  repo 'pebble'
  tag 'v2.0.2'
  # HTTPS ACME API
  port '14000:14000'
  network_mode 'acme'
  env ['PEBBLE_VA_NOSLEEP=1', 'PEBBLE_VA_ALWAYS_VALID=1', 'PEBBLE_WFE_NONCEREJECT=0']
  command 'pebble -config /test/config/pebble-config.json -strict'
end

# Needed for the acme-client gem to continue connecting to pebble;
# please do NOT do this on production Chef nodes!
bash 'update Chef trusted certificates store' do
  code <<-EOC
  cat /opt/src/pebble/test/certs/pebble.minica.pem >> /opt/chef/embedded/ssl/certs/cacert.pem
  touch /opt/chef/embedded/ssl/certs/PEBBLE-MINICA-IS-INSTALLED
  EOC
  creates '/opt/chef/embedded/ssl/certs/PEBBLE-MINICA-IS-INSTALLED'
end
