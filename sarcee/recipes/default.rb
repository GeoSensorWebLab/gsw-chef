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

apt_update

# Install ZFS for Linux
package "zfsutils-linux"

# Find mounted volume from OpenStack
volume_id = node["sarcee"]["docker_volume_id"]
if volume_id.nil? || volume_id.empty?
  raise "Missing docker storage volume ID"
end

volume_path = ""

# Find the path for the volume on this node.
prefix = "/dev/disk/by-id"
ruby_block "find mounted volume path" do
  block do
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    cmd = shell_out("ls #{prefix} | grep #{volume_id}")
    volume_path = "#{prefix}/#{cmd.stdout.chomp}"
  end
end

execute "create zpool" do
  command lazy { "zpool create -f docker_pool #{volume_path}" }
  not_if "zpool list docker_pool"
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

service "docker" do
  action :nothing
end

directory "/etc/docker" do
  action :create
end

file "/etc/docker/daemon.json" do
  content '{ "storage-driver": "zfs" }'
end

bash "create zfs dataset for docker" do
  code <<-EOH
  mv /var/lib/docker /var/lib/docker.bak
  mkdir /var/lib/docker
  zfs create -o mountpoint=/var/lib/docker docker_pool/docker
  EOH
  notifies :stop, "service[docker]", :before
  notifies :start, "service[docker]", :immediate
  not_if "zfs list docker_pool/docker"
end

##################
# 2. Install Dokku
##################

execute "create ssh key" do
  user node["sarcee"]["user"]
  creates "/home/#{node["sarcee"]["user"]}/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f /home/#{node["sarcee"]["user"]}/.ssh/id_rsa -P \"\""
end

apt_repository "dokku" do
  components ["main"]
  key "https://packagecloud.io/dokku/dokku/gpgkey"
  uri "https://packagecloud.io/dokku/dokku/ubuntu/"
end

apt_update

execute "enable vhosts for dokku" do
  command 'echo "dokku dokku/vhost_enable boolean true" | debconf-set-selections'
end
execute "disable web config for dokku" do
  command 'echo "dokku dokku/web_config boolean false" | debconf-set-selections'
end
execute "disable web config for dokku" do
  command "echo \"dokku dokku/key_file string #{node["dokku"]["keyfile"]}\" | debconf-set-selections"
end

package %w(dokku)

# Disable the public HTTP site immediately
service "dokku-installer" do
  action [:stop, :disable]
end

execute "install dokku core plugins" do
  command "dokku plugin:install-dependencies --core"
end

users = search("users", "*:*")

users.each do |user|
  if user["groups"].include?("dokku")
    id = user["id"]

    user["ssh_keys"].each_with_index do |key, i|
      execute "add ssh key #{i+1} for #{id}" do
        command "echo \"#{key}\" | dokku ssh-keys:add #{id}-#{i}"
        sensitive true
      end
    end
  end
end

#####################
# 3. EOL Static Sites
#####################

directory "/var/www/eol-sites" do
  recursive true
  action :create
end

eol_sites_tempdir = "#{Chef::Config[:file_cache_path]}/eol-sites"

git eol_sites_tempdir do
  repository node["sarcee"]["eol_sites_repository"]
end

# Add public keys of people we trust to sign commits
node["gpg"]["import_keys"].each do |key_url|
  execute "import gpg key" do
    command "curl #{key_url} | gpg --import"
  end
end

# Only sync if latest commit is signed with GPG.
# This is done as we are loading nginx configuration from a public
# repository automatically.
execute "check for signed commit" do
  command "git verify-commit HEAD"
  cwd eol_sites_tempdir
end

execute "rsync EOL sites updates" do
  command "rsync -ah --delete #{eol_sites_tempdir}/conf #{eol_sites_tempdir}/sites /var/www/eol-sites/."
end

cookbook_file "/etc/nginx/conf.d/eol-sites.conf" do
  source "eol-sites.conf"
end

service "nginx" do
  action :reload
end

######################
# 4. Create Dokku Apps
######################

dokku_apps = search("apps", "*:*").collect do |app|
  Chef::EncryptedDataBagItem.load("apps", app["id"])
end

dokku_apps.each do |app|
  # Only execute resources for apps marked as "enabled"
  if app["enabled"]
    app_id = app["id"]
    # Avoid running creation command for apps that exist as it is slow
    execute "create app for #{app_id}" do
      command "dokku apps:create #{app_id}"
      not_if "dokku apps:exists #{app_id}"
    end

    execute "set domains for #{app_id}" do
      command "dokku domains:set #{app_id} #{app["domains"].join(" ")}"
    end

    # Convert environment hash to string for CLI
    env = app["env"].reduce("") do |memo, (key, val)|
      memo += " '#{key}'='#{val}'"
      memo
    end

    execute "set environment for #{app_id}" do
      command "dokku config:set #{app_id} #{env}"
      sensitive true
    end
  end
end

###############################
# 5. Setup docker cleaup script
###############################

cookbook_file "/usr/local/sbin/docker-cleanup" do
  source "docker-cleanup.sh"
  mode 755
  owner "root"
  group "root"
end

# Run cleanup once per day at 01:00
file "/etc/cron.d/docker-cleanup" do
  content "0 1 * * * root /usr/local/sbin/docker-cleanup"
  mode 644
  owner "root"
  group "root"
end
