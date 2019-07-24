#
# Cookbook Name:: stoney
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

apt_update

##################
# 1. Install nginx
##################

package %w(nginx-full)

service "nginx" do
  supports [:restart, :reload]
  action :nothing
end

# Create nginx sites for each reverse-proxy
template "/etc/nginx/conf.d/arctic-scholar.conf" do
  source "reverse-proxy-vhost.conf.erb"
  variables({
    domains: ["scholar.arcticconnect.ca"],
    ssl_enabled: false,
    proxy_host: "macleod.gswlab.ca",
    proxy_port: 80
  })
  notifies :reload, "service[nginx]"
end
