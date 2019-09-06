########################
# Cookbook Configuration
########################
default["transloader"]["repository"] = "https://github.com/GeoSensorWebLab/data-transloader"
default["transloader"]["revision"] = "v0.6.1"
# Remember to use the four-letter codes; check the following CSV file:
# http://dd.weather.gc.ca/observations/doc/swob-xml_station_list.csv
default["transloader"]["environment_canada_stations"] = ["CXCM"]

default["transloader"]["data_garrison_stations"] = [
  {
    "name"       => "30 Mile Weather Station",
    "user_id"    => 300234063581640,
    "station_id" => 300234065673960,
    "latitude"   => 69.1580,
    "longitude"  => -107.0403,
    "timezone_offset" => "-06:00"
  },
  {
    "name"       => "Melbourne Island Weather Station",
    "user_id"    => 300234063581640,
    "station_id" => 300234063588720,
    "latitude"   => 68.5948,
    "longitude"  => -104.9363,
    "timezone_offset" => "-06:00"
  }
]

default["sensorthings"]["external_uri"] = "https://sensors.arcticconnect.ca:6443/"

# Arctic Sensors Dashboard
default["dashboard"]["prefix"] = "/opt/community-sensorweb"
default["dashboard"]["repository"] = "https://github.com/GeoSensorWebLab/community-sensorweb"

#######################
# Node.js Configuration
#######################
default["nodejs"]["install_method"] = "binary"
default["nodejs"]["version"] = "10.16.0"
default["nodejs"]["binary"]["checksum"] = "2e2cddf805112bd0b5769290bf2d1bc4bdd55ee44327e826fa94c459835a9d9a"
