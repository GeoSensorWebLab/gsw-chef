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

# Empty the conf.d directory of old vhost entries.
# When a virtualhost is removed from the attributes, then it will have
# its conf removed as well.
execute "empty previous nginx configurations" do
  command "rm /etc/nginx/conf.d/*"
  ignore_failure true
end

# Create nginx sites for each reverse-proxy
vhosts = node["stoney"]["vhosts"]

vhosts.each do |vhost|
  template "/etc/nginx/conf.d/#{vhost["id"]}.conf" do
    source "reverse-proxy-vhost.conf.erb"
    variables({
      domains: vhost["domains"],
      ssl_enabled: vhost["ssl_enabled"],
      proxy_host: vhost["proxy_host"],
      proxy_port: vhost["proxy_port"]
    })
    notifies :reload, "service[nginx]"
  end
end
