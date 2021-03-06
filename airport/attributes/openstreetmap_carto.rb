#########################
## openstreetmap-carto ##
#########################

# Source repo and branch/tag/ref
default[:maps_server][:openstreetmap_carto][:git_ref] = "v4.20.0"
default[:maps_server][:openstreetmap_carto][:git_repo] = "https://github.com/gravitystorm/openstreetmap-carto"

# Postgres Database to be created and loaded with OSM data
default[:maps_server][:openstreetmap_carto][:database_name] = "osm"
# mod_tile path under which tiles will be served via Apache
default[:maps_server][:openstreetmap_carto][:http_path] = "/osm-carto/"
# Recommended bounds (in EPSG:4326) that is sent to map clients
default[:maps_server][:openstreetmap_carto][:bounds] = [-122, 45, -100, 62]

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
default[:maps_server][:openstreetmap_carto][:extracts] = [{
  extract_date_requirement: "2020-03-30T01:00:00+01:00",
  extract_url:              "https://download.geofabrik.de/north-america/canada/alberta-latest.osm.pbf",
  extract_checksum_url:     "https://download.geofabrik.de/north-america/canada/alberta-latest.osm.pbf.md5"
}, {
  extract_date_requirement: "2020-03-30T01:00:00+01:00",
  extract_url:              "https://download.geofabrik.de/north-america/canada/saskatchewan-latest.osm.pbf",
  extract_checksum_url:     "https://download.geofabrik.de/north-america/canada/saskatchewan-latest.osm.pbf.md5"
}]
# Crop the extract to a given bounding box
# Use a blank array or nil for no crop
# Order is the same as used by osm2pgsql:
# min longitude, min latitude, max longitude,
# max latitude
default[:maps_server][:openstreetmap_carto][:crop_bounding_box] = []
# default[:osm2pgsql][:crop_bounding_box] = [-115, 50, -113, 52]

# OSM2PGSQL Node Cache Size in Megabytes
# Default is 800 MB.
default[:maps_server][:openstreetmap_carto][:node_cache_size] = 1600

# Number of processes to use for osm2pgsql import.
# Should match number of threads/cores.
default[:maps_server][:openstreetmap_carto][:import_procs] = 8

###################################
## Default Location for Web Clients
###################################
# This location is Calgary, Canada
default[:maps_server][:openstreetmap_carto][:latitude] = 51.0452
default[:maps_server][:openstreetmap_carto][:longitude] = -114.0625
default[:maps_server][:openstreetmap_carto][:zoom] = 4
