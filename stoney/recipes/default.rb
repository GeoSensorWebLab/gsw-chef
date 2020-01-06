#
# Cookbook Name:: stoney
# Recipe:: default
#
# Copyright 2019–2020 GeoSensorWeb Lab, University of Calgary
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

#################
# 1. Update hosts
#################

include_recipe "gsw-hostsfile::default"

####################
# 2. Install certbot
####################

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

# Filter the vhosts with SSL enabled, and create self-signed certs for
# the domains on that vhost. self-signed are needed to start nginx if 
# existing certs don't exist.
node["stoney"]["vhosts"].each do |vhost|
  if vhost["ssl_enabled"]
    vhost["domains"].each do |domain|
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
  end
end

##################
# 3. Install nginx
##################

package %w(nginx-full)

service "nginx" do
  supports [:restart, :reload]
  action :nothing
end

# Create directory for ACME validations
directory '/var/www/html/.well-known/acme-challenge' do
  recursive true
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create
end

# Empty the conf.d directory of old vhost entries.
# When a virtualhost is removed from the attributes, then it will have
# its conf removed as well.
execute "empty previous nginx configurations" do
  command "rm /etc/nginx/conf.d/*"
  ignore_failure true
end

# Create nginx sites for each reverse-proxy
node["stoney"]["vhosts"].each do |vhost|
  template "/etc/nginx/conf.d/#{vhost["id"]}.conf" do
    source "reverse-proxy-vhost.conf.erb"
    variables({
      domains: vhost["domains"],
      ssl_enabled: vhost["ssl_enabled"],
      proxy_host: vhost["proxy_host"],
      proxy_port: vhost["proxy_port"]
    })
  end
end

service "nginx" do
  action :reload
end

######################
# 4. Install SSL Certs
######################

# Do not use SSL certificate verification with local testing server.
verify = ""
if node['acme']['dir'] == "https://127.0.0.1:14000/dir"
  verify = "--no-verify-ssl"
end

node["stoney"]["vhosts"].each do |vhost|
  if vhost["ssl_enabled"]
    vhost["domains"].each do |domain|
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
          --domains #{domain} \
          --keep-until-expiring --expand --renew-with-new-domains \
          --rsa-key-size 2048 --server "#{node['acme']['dir']}" #{verify}
        EOH
      end
    end
  end
end

service 'nginx' do
  action :reload
end
