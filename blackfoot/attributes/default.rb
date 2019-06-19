########################
# Cookbook Configuration
########################
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

##########################
# PostgreSQL Configuration
##########################
default["postgresql"]["version"] = "11"
default["postgresql"]["data_directory"] = "/srv/data/postgresql/11/main"

####################
# GOST Configuration
####################
# Prefix for all GOST binaries and configuration
default["gost"]["prefix"] = "/opt/gost"
# ZIP file with release of GOST to install
default["gost"]["release"] = "https://github.com/gost/server/releases/download/0.5/gost_ubuntu_x64.zip"
# Repository with database configuration scripts
default["gost"]["database_repository"] = "https://github.com/gost/gost-db.git"
# Name of postgresql database for GOST
default["gost"]["database"] = "gost"
# GOST system user must be the same as the GOST database user for ident
# access.
default["gost"]["user"] = "gost"
# The default advertised URL for entities in SensorThings API
default["gost"]["external_uri"] = "https://sensors.arcticconnect.ca:6443/"

#######################
# Node.js Configuration
#######################
default["nodejs"]["install_method"] = "binary"
default["nodejs"]["version"] = "10.16.0"
default["nodejs"]["binary"]["checksum"] = "2e2cddf805112bd0b5769290bf2d1bc4bdd55ee44327e826fa94c459835a9d9a"
