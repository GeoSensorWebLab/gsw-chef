#
# Cookbook Name:: beddington
# Recipe:: default
#
# Copyright 2021 GeoSensorWeb Lab, University of Calgary
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

# If the zpool does not exist, then this will have a non-zero exit code.
# See the README for manual preconfiguration instructions.
pool_name = "storage"
bash "check for '#{pool_name}' zpool" do
  code <<-EOH
  /usr/sbin/zpool status #{pool_name}
  EOH
end

# If the pool is available, next we create the filesystems.
bash "create zfs filesystem for backups" do
  code <<-EOH
  /usr/sbin/zfs create #{pool_name}/backups
  EOH
  not_if "/usr/sbin/zfs list #{pool_name}/backups"
end

bash "create zfs filesystem for wiki configuration" do
  code <<-EOH
  /usr/sbin/zfs create #{pool_name}/config
  EOH
  not_if "/usr/sbin/zfs list #{pool_name}/config"
end

bash "create zfs filesystem for docker" do
  code <<-EOH
  /usr/sbin/zfs create #{pool_name}/docker
  EOH
  not_if "/usr/sbin/zfs list #{pool_name}/docker"
end

bash "set zfs quota for docker" do
  code <<-EOH
  /usr/sbin/zfs set quota=#{node["beddington"]["docker_quota"]} #{pool_name}/docker
  EOH
end

# Set up Docker using 'docker' cookbook resources
docker_service "default" do
  action [:create, :start]
end

# Install Docker Compose
remote_file "/usr/local/bin/docker-compose" do
  source "https://github.com/docker/compose/releases/download/#{node["docker_compose"]["version"]}/docker-compose-#{node["docker_compose"]["os"]}-#{node["docker_compose"]["arch"]}"
  checksum node["docker_compose"]["sha256"]
  mode "0755"
  owner "root"
  group "root"
end

# Switch to ZFS storage driver for Docker
cookbook_file "/etc/docker/daemon.json" do
  source "docker-daemon.json"
  notifies :restart, "docker_service[default]", :immediately
end

