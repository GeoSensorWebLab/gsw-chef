#
# Cookbook Name:: edmonton
# Recipe:: default
#
# Copyright 2020 GeoSensorWeb Lab, University of Calgary
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

# Update package cache before installing any packages.
apt_update

# Install ZFS for Linux
package "zfsutils-linux"

# Install Munin Server
package "munin"
package "apache2"
package "rrdcached"
package "libcgi-fast-perl"
package "libapache2-mod-fcgid"

template "/etc/default/rrdcached" do
  source "rrdcached.erb"
  owner "root"
  group "root"
  mode "644"
end

directory "/var/lib/munin/rrdcached" do
  owner "munin"
  group "munin"
  mode 0o755
end

service "rrdcached" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/default/rrdcached]"
end

expiry_time = 14 * 86400

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  owner "root"
  group "root"
  mode 0o644
  variables :expiry_time => expiry_time
end

template "/etc/apache2/sites-available/munin.conf" do
  source "apache/munin.conf.erb"
end

%w(fcgid rewrite headers).each do |apache_module|
  execute "enable apache module #{apache_module}" do
    command "a2enmod #{apache_module}"
  end
end

execute "enable munin site" do
  command "a2ensite munin"
end

service "apache2" do
  action :restart
end

# Install Munin Client
package "munin-node"
package "ruby"
package "libdbd-pg-perl"

# Install plugins to /usr/local/share/munin/plugins/
plugins_dir = "/usr/local/share/munin/plugins"

directory plugins_dir do
  recursive true
  action :create
end

# Enable plugins by creating links in /etc/munin/plugins/
execute "enable default munin node plugins" do
  command "munin-node-configure --suggest --shell | sh"
end

service "munin-node" do
  action :restart
end

service "rrdcached" do
  action :restart
end

service "apache2" do
  action :restart
end