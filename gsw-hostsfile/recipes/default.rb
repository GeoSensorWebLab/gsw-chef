#
# Cookbook Name:: gsw-hostsfile
# Recipe:: default
#
# Copyright 2019–2021 GeoSensorWeb Lab, University of Calgary
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

node["gsw-hostsfile"]["hostsfile"].each do |host|
  hostsfile_entry host["ip"] do
    hostname  host["hostname"]
    unique    true
    action    :create
  end
end
