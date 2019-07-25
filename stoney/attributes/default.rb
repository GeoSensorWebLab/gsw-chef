# Hostsfile entries for this proxy server.
# These are used for having a shorthand domain that can be used in vhost
# definitions, and so that changes to IPs can be updated in one 
# location.
default["stoney"]["hostsfile"] = [
  { "hostname" => "airport.gswlab.ca", "ip" => "10.1.14.229" },
  { "hostname" => "banff.gswlab.ca", "ip" => "10.1.1.98" },
  { "hostname" => "barlow.gswlab.ca", "ip" => "10.1.11.170" },
  { "hostname" => "blackfoot.gswlab.ca", "ip" => "10.1.11.89" },
  { "hostname" => "bow.gswlab.ca", "ip" => "10.1.4.6" },
  { "hostname" => "cowboy.gswlab.ca", "ip" => "10.1.9.179" },
  { "hostname" => "crowchild.gswlab.ca", "ip" => "10.1.10.243" },
  { "hostname" => "deerfoot.gswlab.ca", "ip" => "10.1.6.106" },
  { "hostname" => "macleod.gswlab.ca", "ip" => "10.1.0.186" },
  { "hostname" => "sarcee.gswlab.ca", "ip" => "10.1.11.237" },
  { "hostname" => "shaganappi.gswlab.ca", "ip" => "10.1.0.158" },
  { "hostname" => "stoney.gswlab.ca", "ip" => "10.1.0.111" }
]

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
  "id"          => "arctic-maps",
  "domains"     => ["arctic-maps.gswlab.ca", "maps.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "deerfoot.gswlab.ca",
  "proxy_port"  => 8080
}, {
  "id"          => "arctic-bio-map",
  "domains"     => ["abm-demo.gswlab.ca", "arctic-biomap-sightings.gswlab.ca", "abm-demo.arcticconnect.ca", "sightings.arcticconnect.ca"],
  "ssl_enabled" => false,
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
  "ssl_enabled" => false,
  "proxy_host"  => "sarcee.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "arctic-sensor-web-expansion",
  "domains"     => ["arctic-sensors.gswlab.ca", "sensors.arcticconnect.ca"],
  "ssl_enabled" => true,
  "proxy_host"  => "blackfoot.gswlab.ca",
  "proxy_port"  => 80
}, {
  "id"          => "bera-dashboard",
  "domains"     => ["dashboard.geocens.ca", "dashboard.gswlab.ca", "dashboard.bera-project.org"],
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
}, {
  "id"          => "dataservice-web",
  "domains"     => ["dataservice-web.geocens.ca", "dataservice-web.gswlab.ca"],
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
