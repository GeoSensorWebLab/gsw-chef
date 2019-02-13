#
# Cookbook Name:: crowchild
# Recipe:: default
#
# Copyright 2018 GeoSensorWeb Lab, University of Calgary
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
require 'securerandom'

# Install build tools for Ruby
package 'build-essential' do
  action :nothing
end.run_action(:install)

chef_gem 'bcrypt' do
  action :nothing
  compile_time false
end.run_action(:install)
require 'bcrypt'

# 1. Install Icinga Apt Repository
# https://packages.icinga.com/ubuntu/

apt_repository 'icinga' do
  uri 'http://packages.icinga.com/ubuntu'
  distribution 'icinga-bionic'
  components ['main']
  key 'https://packages.icinga.com/icinga.key'
end

# 2. Install Icinga 2
# https://icinga.com/docs/icinga2/latest/doc/02-getting-started/

package 'icinga2'

service 'icinga2' do
  action :nothing
end

# 3. Install PostgreSQL for Icinga 2

postgresql_server_install 'postgresql-10' do
  version '10'
  initdb_locale 'en_US.UTF-8'
end

package 'icinga2-ido-pgsql'

# Generate a random password for Icinga DB connection
icinga_db_pass = SecureRandom.alphanumeric(24)

# Create role in Postgres for icinga
postgresql_user 'icinga' do
  password icinga_db_pass
  sensitive true
end

# If the user already exists, the previous resource is skipped but we
# still need to update the password
postgresql_user 'icinga' do
  password icinga_db_pass
  sensitive true
  action :update
end

# Create DB for icinga
postgresql_database 'icinga' do
  owner 'icinga'
  template 'template0'
end

file '/root/.pgpass' do
  content "localhost:5432:icinga:icinga:#{icinga_db_pass}"
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
end

# Load the database for Icinga 2
bash 'Load Icinga 2 DB' do
  code <<-EOH
  psql -U icinga -d icinga -h localhost -p 5432 < /usr/share/icinga2-ido-pgsql/schema/pgsql.sql && \
  touch /opt/icinga_db_imported
  EOH
  sensitive true

  not_if { ::File.exists?('/opt/icinga_db_imported') }
end

# Update IDO Configuration
template '/etc/icinga2/features-available/ido-pgsql.conf' do
  source 'ido-pgsql.conf.erb'
  sensitive true
  variables({
    db: "icinga",
    host: "localhost",
    password: icinga_db_pass,
    user: "icinga"
  })
end

# Enable IDO PostgreSQL module
execute "Enable IDO PostgreSQL module" do
  command "icinga2 feature enable ido-pgsql"
  notifies :restart, 'service[icinga2]', :delayed
end

# Enable Icinga 2 REST API
execute "able Icinga 2 REST API" do
  command "icinga2 api setup"
end

icingaweb_rest_password = SecureRandom.alphanumeric(24)

template '/etc/icinga2/conf.d/api-users.conf' do
  source 'api-users.conf.erb'
  sensitive true
  variables({
    root_password: SecureRandom.alphanumeric(24),
    users: [{
      name: 'icingaweb2',
      password: icingaweb_rest_password,
      permissions: ["status/query", "actions/*", "objects/modify/*", "objects/query/*"]
    }]
  })
  notifies :restart, 'service[icinga2]', :delayed
end

# 4. Install Apache, PHP, Icinga Web 2
# https://icinga.com/docs/icingaweb2/latest/doc/02-Installation/
package %w(apache2 libapache2-mod-php icingaweb2 icingacli)

service 'apache2' do
  action :nothing
end

# Enable the Apache SSL module before a vhost asks for it
execute "Enable Apache2 SSL Module" do
  command 'a2enmod ssl'
  not_if { ::File.exists?('/etc/apache2/mods-enabled/ssl.load') }
  notifies :restart, 'service[apache2]', :immediately
end

# Install Icinga Web 2 dependencies
package %w(php php-intl php-imagick php-gd php-curl php-mbstring php-pgsql)

ruby_block "Set default PHP timezone" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/php/7.2/apache2/php.ini")
    fe.insert_line_if_no_match(/^date.timezone = America\/Edmonton$/,
                               "date.timezone = America\/Edmonton")
    fe.write_file
  end
end

icingaweb2_db_pass = SecureRandom.alphanumeric(24)

# Create role in Postgres for icingaweb2
postgresql_user 'icingaweb2' do
  password icingaweb2_db_pass
  sensitive true
end

# If the user already exists, the previous resource is skipped but we
# still need to update the password
postgresql_user 'icingaweb2' do
  password icingaweb2_db_pass
  sensitive true
  action :update
end

# Create DB for icingaweb2
postgresql_database 'icingaweb2' do
  owner 'icingaweb2'
  template 'template0'
end

file '/root/.pgpass' do
  content "localhost:5432:icingaweb2:icingaweb2:#{icingaweb2_db_pass}"
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
end

# Load the database for Icinga Web 2
bash 'Load Icinga Web 2 DB' do
  code <<-EOH
  psql -U icingaweb2 -d icingaweb2 -h localhost -p 5432 < /usr/share/icingaweb2/etc/schema/pgsql.schema.sql && \
  touch /opt/icinga_web_db_imported
  EOH
  sensitive true

  not_if { ::File.exists?('/opt/icinga_web_db_imported') }
end

# Create Icinga Web 2 user accounts for all users in "icinga_users" 
# vault/data bag  who have `enabled = true`
icingaweb2_admins = []
icingaweb2_readers = []
users = search(:icinga_users, "*:*")

users.each do |user|
  d_user = chef_vault_item('icinga_users', user["id"])
  if d_user["enabled"]
    
    username = d_user["id"]
    password = d_user["password"]

    if d_user["admin"]
      icingaweb2_admins.push(username)
    else
      icingaweb2_readers.push(username)
    end

    hash_pw = BCrypt::Password.create(password).to_s

    bash "Add Icinga Web 2 User" do
      code <<-EOH
      /usr/bin/psql -U icingaweb2 -d icingaweb2 -h localhost -p 5432 \
        <<'EOF'
        INSERT INTO icingaweb_user (name, active, password_hash) \
        VALUES ('#{username}', 1, '#{hash_pw}') ON CONFLICT (name) \
        DO UPDATE SET password_hash = '#{hash_pw}' \
        WHERE icingaweb_user.name = '#{username}';
        EOF
      EOH
      sensitive true
    end
  end
end

template '/etc/apache2/sites-available/monitoring.conf' do
  source 'monitoring.conf.erb'
end

execute "Enable Icinga Web 2 Apache Site" do
  command 'a2ensite monitoring'
  notifies :restart, 'service[apache2]', :immediately
end

execute "Create Icinga Web 2 Configuration" do
  command 'icingacli setup config directory'
end

# Use Chef to build Icinga Web 2 configuration instead of using web
# configuration wizard
template '/etc/icingaweb2/authentication.ini' do
  source 'icingaweb2/authentication.ini.erb'
end

directory '/etc/icingaweb2/modules/monitoring' do
  recursive true
  action :create
end

template '/etc/icingaweb2/modules/monitoring/config.ini' do
  source 'icingaweb2/monitoring/config.ini.erb'
end

template '/etc/icingaweb2/modules/monitoring/instances.ini' do
  source 'icingaweb2/monitoring/instances.ini.erb'
end

template '/etc/icingaweb2/modules/monitoring/backends.ini' do
  source 'icingaweb2/monitoring/backends.ini.erb'
end

template '/etc/icingaweb2/modules/monitoring/commandtransports.ini' do
  source 'icingaweb2/monitoring/commandtransports.ini.erb'
  variables({
    password: icingaweb_rest_password
  })
  sensitive true
end

template '/etc/icingaweb2/roles.ini' do
  source 'icingaweb2/roles.ini.erb'
  variables({
    admins: icingaweb2_admins,
    readers: icingaweb2_readers
  })
end

template '/etc/icingaweb2/config.ini' do
  source 'icingaweb2/config.ini.erb'
end

directory '/etc/icingaweb2/enabledModules' do
  action :create
end

template '/etc/icingaweb2/resources.ini' do
  source 'icingaweb2/resources.ini.erb'
  variables({
    db_host: "localhost",
    db_port: "5432",
    icingaweb2_db_name: "icingaweb2",
    icingaweb2_db_user: "icingaweb2",
    icingaweb2_db_pass: icingaweb2_db_pass,
    icinga2_db_name: "icinga",
    icinga2_db_user: "icinga",
    icinga2_db_pass: icinga_db_pass
  })
  sensitive true
end

directory '/etc/icingaweb2' do
  owner 'root'
  group 'icingaweb2'
  recursive true
end

execute "Enable Monitoring Module" do
  command 'icingacli module enable monitoring'
end

# Set up HTTPS virtualhosts with self-signed certs
# Self-signed are used as Apache will fail to start with missing certs,
# and Apache must be running for certbot to work to fetch real certs.

template '/etc/apache2/sites-available/monitoring-ssl.conf' do
  source 'monitoring-ssl.conf.erb'
  variables({
    certificate_file: "/etc/ssl/certs/ssl-cert-snakeoil.pem",
    certificate_key_file: "/etc/ssl/private/ssl-cert-snakeoil.key"
  })
end

execute "Enable Icinga Web 2 SSL Apache Site" do
  command 'a2ensite monitoring-ssl'
  not_if { ::File.exists?('/etc/apache2/sites-enabled/monitoring-ssl.conf') }
  notifies :restart, 'service[apache2]', :immediately
end

# Install HTTPS certificates
apt_repository 'certbot' do
  uri 'ppa:certbot/certbot'
end

package 'certbot'

https_admin_email = node['crowchild']['https_admin_email']

# Configuration for Certbot.
# Do not get real certs if running under test kitchen.
unless node['crowchild']['ignore_real_certs']
  execute 'get certs' do
    command "certbot certonly -n --agree-tos -m #{https_admin_email} \
    --webroot -w '/usr/share/icingaweb2/public' \
    -d monitoring.gswlab.ca,monitoring.arcticconnect.ca"
  end

  template '/etc/apache2/sites-available/monitoring-ssl.conf' do
    source 'monitoring-ssl.conf.erb'
    variables({
      certificate_file: "/etc/letsencrypt/live/monitoring.gswlab.ca/cert.pem",
      certificate_key_file: "/etc/letsencrypt/live/monitoring.gswlab.ca/privkey.pem"
    })
    notifies :restart, 'service[apache2]', :delayed
  end
end

# Install NTP for local clock synchronization
package 'ntp'

# Install/Configure Munin (primary controller)
package 'munin'

template '/etc/apache2/sites-available/monitoring.conf' do
  source 'monitoring.conf.erb'
  variables({
    enable_munin: true
  })
  notifies :restart, 'service[apache2]', :delayed
end

unless node['crowchild']['ignore_real_certs']
  template '/etc/apache2/sites-available/monitoring-ssl.conf' do
    source 'monitoring-ssl.conf.erb'
    variables({
      certificate_file: "/etc/letsencrypt/live/monitoring.gswlab.ca/cert.pem",
      certificate_key_file: "/etc/letsencrypt/live/monitoring.gswlab.ca/privkey.pem",
      enable_munin: true
    })
    notifies :restart, 'service[apache2]', :delayed
  end
end

# Select all hosts that have munin-node installed
# I tried to do a node search for nodes that have 'munin-node' installed
# but for an unknown reason only the 'crowchild' node shows up.
munin_nodes = ['shaganappi']
munin_hosts = search(:node, "*:*")

munin_hosts = munin_hosts.select { |n|
  munin_nodes.include?(n[:name])
}

template '/etc/munin/munin.conf' do
  source 'munin.conf.erb'
  variables({
    hosts: munin_hosts
  })
end

# Install/Configure Munin Node (for this node/machine)
# libwww-perl enables Apache plugins for Munin
package 'libwww-perl'

# libdbd-pg-perl enables Postgresql plugins for Munin
package 'libdbd-pg-perl'

execute 'update munin-node configuration' do
  command 'munin-node-configure --shell | sh'
end

service 'munin-node' do
  action :restart
end

# Update Icinga Configuration

# Custom Plugins
plugins_directory = node['icinga2']['plugins_directory']

# Custom Plugin: Domain Expiration Check
package 'whois'

cookbook_file "#{plugins_directory}/check_domain_expiration" do
  source 'check_domain_expiration.sh'
  owner 'root'
  group 'root'
  mode '0755'
end

# Icinga2: Commands
template '/etc/icinga2/conf.d/commands.conf' do
  source 'icinga2/commands.conf.erb'
  variables()
  notifies :restart, 'service[icinga2]', :delayed
end

# Icinga2: Groups
template '/etc/icinga2/conf.d/groups.conf' do
  source 'icinga2/groups.conf.erb'
  variables()
  notifies :restart, 'service[icinga2]', :delayed
end

# If the node does not have ipv6, then ipv6 checks from this Icinga2
# instance will be omitted
node_has_ipv6 = !node['network']['default_inet6_interface'].nil?

# Icinga2: Hosts
hosts = node['icinga2']['host_objects']

template '/etc/icinga2/conf.d/hosts.conf' do
  source 'icinga2/hosts.conf.erb'
  variables({
    has_ipv6: node_has_ipv6,
    host_objects: hosts
  })
  notifies :restart, 'service[icinga2]', :delayed
end

# Icinga2: Services
services = node['icinga2']['service_objects']

template '/etc/icinga2/conf.d/services.conf' do
  source 'icinga2/services.conf.erb'
  variables({
    has_ipv6: node_has_ipv6,
    service_objects: services
  })
  notifies :restart, 'service[icinga2]', :delayed
end
