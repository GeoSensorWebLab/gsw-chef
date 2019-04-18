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

include_recipe 'acme::default'

# Configure the apt repository for nginx
apt_repository 'nginx' do
  uri          'http://nginx.org/packages/mainline/ubuntu/'
  components   ['nginx']
  deb_src      true
  distribution node['lsb']['codename']
  key          'http://nginx.org/keys/nginx_signing.key'
end

# Set up self-signed SSL certificates so nginx can load
include_recipe 'acme::default'

directory '/etc/ssl/letsencrypt' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Create self-signed cert for each HTTPS domain
# self-signed are needed to start nginx if existing certs don't exist
node['banff']['https_domains'].each do |domain|
  acme_selfsigned domain do
    crt     "/etc/ssl/letsencrypt/#{domain}.crt"
    chain   "/etc/ssl/letsencrypt/#{domain}-chain.crt"
    key     "/etc/ssl/letsencrypt/#{domain}.key"
    owner   'www-data'
  end
end

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

cookbook_file '/etc/nginx/conf.d/default.conf' do
  source 'default.conf'
  owner 'nginx'
  group 'nginx'
  mode '0644'
end

# Reload nginx
service 'nginx' do
  action :reload
end

# Create real certificates for https domains
node['banff']['https_domains'].each do |ssl_domain|
  # Delete cert and key if they are self-signed, so that LE can generate new
  # ones. This openssl command will return 0 if the cert is self-signed.
  bash 'remove self-signed' do
    cwd '/etc/ssl/letsencrypt'
    code <<-EOH
      openssl verify -CAfile #{ssl_domain}.crt #{ssl_domain}.crt 2> /dev/null
      if [ $? -eq 0 ]; then
        rm #{ssl_domain}.crt #{ssl_domain}.key
      fi
      EOH
  end

  acme_certificate ssl_domain do
    crt       "/etc/ssl/letsencrypt/#{ssl_domain}.crt"
    key       "/etc/ssl/letsencrypt/#{ssl_domain}.key"
    alt_names ["a.#{ssl_domain}", "b.#{ssl_domain}", "c.#{ssl_domain}"]
    owner     'www-data'
    wwwroot   '/var/www/html'
  end
end

service 'nginx' do
  action :reload
end
