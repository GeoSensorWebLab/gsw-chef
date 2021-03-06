#########
## Locale
#########
default["edmonton"]["locale"] = "en_CA"

##################################
## Installation Directory Prefixes
##################################
# For software packages
default["edmonton"]["software_prefix"] = "/opt"
# For map source data downloads
default["edmonton"]["data_prefix"] = "/tiledb/data"

##################
## Extract Sources
##################
# If extract date is set and any existing extract is older, then
# A) a new extract will be downloaded
# B) the local OSM database will be reloaded
# C) The database will be re-vacuumed after import
# D) stylesheet-specific indexes will be created again
# Date should be ISO8601 with a timezone. Leave as nil or empty string
# to ignore.
# For extract URLs, use PBF files only.
default["edmonton"]["extracts"] = [{
  extract_date_requirement: "2020-02-04T12:00:00+00:00",
  extract_url:              "https://download.geofabrik.de/north-america/canada/nunavut-latest.osm.pbf",
  extract_checksum_url:     "https://download.geofabrik.de/north-america/canada/nunavut-latest.osm.pbf.md5"
}]

default["ne_water"]["download_url"] = "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/ne_110m_ocean.zip"
default["osm_water"]["download_url"] = "https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip"

#################
## Rendering User
#################
default["edmonton"]["render_user"] = "render"

# OSM2PGSQL Node Cache Size in Megabytes
# Default is 800 MB.
default["edmonton"]["node_cache_size"] = 800

# Number of processes to use for osm2pgsql import.
# Should match number of threads/cores.
default["edmonton"]["import_procs"] = 6

#######
## PROJ
#######
default["proj"]["version"] = "6.3.0"
default["proj"]["download_url"] = "https://download.osgeo.org/proj/proj-6.3.0.tar.gz"
default["proj_datumgrid"]["version"] = "1.8"
default["proj_datumgrid"]["download_url"] = "https://download.osgeo.org/proj/proj-datumgrid-1.8.zip"

#######
## GDAL
#######
default["gdal"]["version"] = "3.0.4"
default["gdal"]["download_url"] = "https://github.com/OSGeo/gdal/releases/download/v3.0.4/gdal-3.0.4.tar.gz"

##########
## OpenJDK
##########
default["openjdk"]["version"]       = "13.0.2"
default["openjdk"]["prefix"]        = "/opt/java"
default["openjdk"]["download_url"]  = "https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_linux-x64_bin.tar.gz"
default["openjdk"]["checksum_url"]  = "https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_linux-x64_bin.tar.gz.sha256"
default["openjdk"]["checksum_type"] = "SHA256"

################
## Apache Tomcat
################
default["tomcat"]["version"]       = "9.0.30"
default["tomcat"]["user"]          = "tomcat"
default["tomcat"]["Xms"]           = "256m"
default["tomcat"]["Xmx"]           = "4g"
default["tomcat"]["prefix"]        = "/opt/tomcat"
default["tomcat"]["download_url"]  = "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.30/bin/apache-tomcat-9.0.30.tar.gz"
default["tomcat"]["checksum_url"]  = "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.30/bin/apache-tomcat-9.0.30.tar.gz.sha512"
default["tomcat"]["checksum_type"] = "SHA512"

############
## GeoServer
############
default["geoserver"]["version"]                            = "2.16.2"
default["geoserver"]["prefix"]                             = "/opt/geoserver"
default["geoserver"]["data_directory"]                     = "/tiledb/geoserver/data"
default["geoserver"]["default_master_username"]            = "admin"
default["geoserver"]["default_master_password"]            = "geoserver"
default["geoserver"]["master_password_updated"]            = false
default["geoserver"]["admin_password_updated"]             = false
default["geoserver"]["download_url"]                       = "http://sourceforge.net/projects/geoserver/files/GeoServer/2.16.2/geoserver-2.16.2-war.zip"
default["geoserver"]["vectortiles_plugin"]["download_url"] = "http://sourceforge.net/projects/geoserver/files/GeoServer/2.16.2/extensions/geoserver-2.16.2-vectortiles-plugin.zip"
default["geoserver"]["css_plugin"]["download_url"]         = "http://sourceforge.net/projects/geoserver/files/GeoServer/2.16.2/extensions/geoserver-2.16.2-css-plugin.zip"
