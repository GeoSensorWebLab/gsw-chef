#########
## Locale
#########
default[:edmonton][:locale] = "en_CA"

##################################
## Installation Directory Prefixes
##################################
# For software packages
default[:edmonton][:software_prefix] = "/opt"
# For map source data downloads
default[:edmonton][:data_prefix] = "/tiledb/data"

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
default[:edmonton][:extracts] = [{
  extract_date_requirement: "2020-02-04T12:00:00+00:00",
  extract_url:              "https://download.geofabrik.de/north-america/canada/nunavut-latest.osm.pbf",
  extract_checksum_url:     "https://download.geofabrik.de/north-america/canada/nunavut-latest.osm.pbf.md5"
}]
