# Virtual host definitions for this proxy server.
# If `ssl_enabled` is true, then an HTTPS cert will be requested from
# Let's Encrypt for each domain in `domains`.
default["stoney"]["vhosts"] = [{
  "id"          => "arctic-scholar",
  "domains"     => ["arctic-scholar-index.gswlab.ca", "scholar.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "macleod.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-scholar-records",
  "domains"     => ["arctic-scholar.gswlab.ca", "records.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-web-map",
  "domains"     => ["arctic-web-map.gswlab.ca", "webmap.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-web-map-tiles",
  "domains"     => ["arctic-web-map-tiles.gswlab.ca", "tiles.arcticconnect.ca", "a.tiles.arcticconnect.ca", "b.tiles.arcticconnect.ca", "c.tiles.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "airport.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-maps",
  "domains"     => ["arctic-maps.gswlab.ca", "maps.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "deerfoot.gswlab.ca",
  "proxy_port"  => 8080
}, {
  "id"          => "arctic-bio-map",
  "domains"     => ["abm-demo.gswlab.ca", "arctic-biomap-sightings.gswlab.ca", "abm-demo.arcticconnect.ca", "sightings.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-portal",
  "domains"     => ["arctic-portal.gswlab.ca", "portal.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-sensor-web",
  "domains"     => ["arctic-sensor-web.gswlab.ca", "sensorweb.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-sensor-web-expansion",
  "domains"     => ["arctic-sensors.gswlab.ca", "sensors.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "blackfoot.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "asw-airflow",
  "domains"     => ["asw-airflow.gswlab.ca", "asw-airflow.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "blackfoot.gswlab.ca",
  "proxy_port"  => 2080
}, {
  "id"          => "bera-dashboard",
  "domains"     => ["dashboard.geocens.ca", "dashboard.gswlab.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "geocens-portal",
  "domains"     => ["dev.geocens.ca", "geocens.gswlab.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "eaglewatch-portal",
  "domains"     => ["eaglewatch.geocens.ca", "eaglewatch.gswlab.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "rvcww-portal",
  "domains"     => ["rockyview.gswlab.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "aafc-portal",
  "domains"     => ["aafc.geocens.ca", "aafc.gswlab.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "sta-time-vis",
  "domains"     => ["visualize.geocens.ca", "visualize.gswlab.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "sta-webcam",
  "domains"     => ["webcam.geocens.ca", "webcam.gswlab.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}]

# ACME Configuration for HTTPS
default["acme"]["dir"] = "https://acme-v02.api.letsencrypt.org/directory"
default["acme"]["email"] = "jpbadger@ucalgary.ca"

# You may have to use a different key server from the pool:
# https://sks-keyservers.net/overview-of-pools.php
default["certbot"]["keyserver"] = "na.pool.sks-keyservers.net"
default["certbot"]["prefix"] = "/opt/src/certbot"

default["pebble"]["repository"] = "https://github.com/letsencrypt/pebble"
default["pebble"]["version"] = "v2.0.2"
