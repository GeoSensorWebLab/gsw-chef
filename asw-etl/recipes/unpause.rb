#
# Cookbook Name:: asw-etl
# Recipe:: unpause
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

airflow_home = node["airflow"]["home"]

bash "Unpause all DAGs" do
  code <<-EOH
  for file in *.py; do
    dag=$(basename $file .py)
    airflow unpause $dag
  done
  EOH
  cwd "#{airflow_home}/dags"
  env({
    "AIRFLOW_HOME" => airflow_home
  })
end
