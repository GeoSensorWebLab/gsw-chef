#
# Cookbook Name:: gsw-frost-server
# Recipe:: default
#
# Copyright 2020–2021 GeoSensorWeb Lab, University of Calgary
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
include_recipe "chef-vault::default"

apt_update

docker_service "default" do
  action [:create, :start]
end

docker_network "frost_server_net" do
  action :create
end

# Load ENV for FROST Server
frost_vault = chef_vault_item(
  node["frost_server"]["frost_env_vault"],
  node["frost_server"]["frost_env_item"])

# Optionally deploy PostGIS for FROST Server.
# If not set, then you must specify an external database in the
# persistence DB URL.
if node["frost_server"]["deploy_postgis"]
  docker_image "postgis/postgis" do
    tag "latest"
    action :pull
  end

  docker_volume "frost_server_db_volume" do
    action :create
  end

  postgres_db_name  = "sensorthings"
  postgres_user     = "sensorthings"
  postgres_password = "sample"

  docker_container "frost_server_database" do
    repo "postgis/postgis"
    tag "latest"
    restart_policy "always"
    volumes ["frost_server_db_volume:/var/lib/postgresql/data"]
    env [
      "POSTGRES_DB=#{postgres_db_name}",
      "POSTGRES_USER=#{postgres_user}",
      "POSTGRES_PASSWORD=#{postgres_password}",
    ]
    action :run
  end

  docker_network "frost_server_net" do
    container "frost_server_database"
    action :connect
  end
end

docker_image node["frost_server"]["docker_repo"] do
  tag node["frost_server"]["docker_tag"]
  action :pull
end

# Convert env Hash to Array for Docker
container_env = frost_vault["env"].reduce([]) do |memo, pair|
  memo.push("#{pair[0]}=#{pair[1].to_s}")
  memo
end

docker_container "frost_server_web" do
  repo node["frost_server"]["docker_repo"]
  tag node["frost_server"]["docker_tag"]
  restart_policy "always"
  env container_env
  port ["1883:1883", "8080:8080"]
  action :run
end

docker_network "frost_server_net" do
  container "frost_server_web"
  action :connect
end
