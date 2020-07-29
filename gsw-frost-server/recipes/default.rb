#
# Cookbook Name:: gsw-frost-server
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

docker_service "default" do
  action [:create, :start]
end

docker_image "postgis/postgis" do
  tag "latest"
  action :pull
end

docker_image "fraunhoferiosb/frost-server" do
  tag "latest"
  action :pull
end

docker_volume "frost_server_db_volume" do
  action :create
end

postgres_db_name  = "sensorthings"
postgres_user     = "sensorthings"
postgres_password = "asdf"

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

docker_container "frost_server_web" do
  repo "fraunhoferiosb/frost-server"
  tag "latest"
  restart_policy "always"
  env [
    "http_cors_enable=true",
    "http_cors_allowed.origins=<%= @http_cors_allowed_origins %>",
    "persistence_db_driver=org.postgresql.Driver",
    "persistence_db_url=jdbc:postgresql://frost_server_database:5432/#{postgres_db_name}",
    "persistence_db_username=#{postgres_user}",
    "persistence_db_password=#{postgres_password}",
    "persistence_autoUpdateDatabase=true"
  ]
  port ["1883:1883", "8080:8080"]
  action :run
end
