#
# Cookbook Name:: banff
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

#################
# 1. Update hosts
#################

hosts = node["banff"]["hosts"]

node["banff"]["hostsfile"].each do |host|
  hostsfile_entry host["ip"] do
    hostname  host["hostname"]
    unique    true
    action    :create
  end
end

# Configure the apt repository for nginx
apt_repository 'nginx' do
  uri          'http://nginx.org/packages/mainline/ubuntu/'
  components   ['nginx']
  deb_src      true
  distribution node['lsb']['codename']
  key          'http://nginx.org/keys/nginx_signing.key'
end

apt_update

# Install certbot auto instead of package, to get the latest version
directory node["certbot"]["prefix"] do
  recursive true
  action :create
end

certbot_auto = "#{node["certbot"]["prefix"]}/certbot-auto"

remote_file certbot_auto do
  source 'https://dl.eff.org/certbot-auto'
  mode '0755'
  action :create
end

remote_file "#{node["certbot"]["prefix"]}/certbot-auto.asc" do
  source 'https://dl.eff.org/certbot-auto.asc'
  action :create
end

bash 'verify certbot-auto' do
  code <<-EOH
    gpg --keyserver #{node["certbot"]["keyserver"]} --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2
    gpg --trusted-key 4D17C995CD9775F2 --verify certbot-auto.asc certbot-auto
  EOH
  cwd node["certbot"]["prefix"]
  user 'root'
end

execute 'install certbot' do
  command "#{certbot_auto} --non-interactive --install-only"
  cwd node["certbot"]["prefix"]
  user 'root'
end

# Create self-signed cert for each HTTPS domain
# self-signed are needed to start nginx if existing certs don't exist
node['banff']['https_domains'].each do |domain|
  directory "/etc/letsencrypt/live/#{domain}" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  openssl_x509_certificate "/etc/letsencrypt/live/#{domain}/fullchain.pem" do
    common_name domain
    key_file "/etc/letsencrypt/live/#{domain}/privkey.pem"
    expire 1
    owner 'www-data'
    not_if { ::File.exist?("/etc/letsencrypt/live/#{domain}/fullchain.pem") }
  end
end

package 'dnsmasq'

# Install nginx
package 'nginx'

# Create directory for ACME validations
directory '/var/www/html/.well-known/acme-challenge' do
  recursive true
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create
end

# Create cache directory
directory '/scratch/nginx' do
  owner 'nginx'
  group 'nginx'
  recursive true
  action :create
end

# Install custom nginx config
cookbook_file '/etc/nginx/nginx.conf' do
  source 'nginx.conf'
  owner 'nginx'
  group 'nginx'
  mode '0644'
end

template '/etc/nginx/conf.d/default.conf' do
  source 'default-site.conf.erb'
  owner 'nginx'
  group 'nginx'
  mode '0644'
  variables(domains: node["banff"]["https_domains"])
end

# Reload nginx
service 'nginx' do
  action [:enable, :start, :reload]
end

# Do not use SSL certificate verification with local testing server.
verify = ""
if node['acme']['dir'] == "https://127.0.0.1:14000/dir"
  verify = "--no-verify-ssl"
end

node['banff']['https_domains'].each do |domain|
  # remove self-signed certificates
  bash "remove self-signed" do
    cwd "/etc/letsencrypt/live"
    code <<-EOH
      openssl verify "#{domain}/fullchain.pem" 2>&1 | grep -q "self signed"
      if [ $? -eq 0 ]; then
        rm -rf "/etc/letsencrypt/live/#{domain}"
      fi
      EOH
  end

  execute "certbot" do
    command <<-EOH
    #{certbot_auto} certonly --noninteractive --agree-tos -m #{node["acme"]["email"]} \
      --webroot --webroot-path /var/www/html \
      --domains #{domain},a.#{domain},b.#{domain},c.#{domain} \
      --keep-until-expiring --expand --renew-with-new-domains \
      --rsa-key-size 2048 --server "#{node['acme']['dir']}" #{verify}
    EOH
  end
end

service 'nginx' do
  action :reload
end
