# Hostsfile entries for this node.
# These are used for having a shorthand domain that can be used in vhost
# definitions, and so that changes to IPs can be updated in one 
# location.
default["banff"]["hostsfile"] = [
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

default["banff"]["https_domains"] = [
  "tiles.arcticconnect.ca",
  # "tiles.arcticconnect.org",
  "arctic-web-map-tiles.gswlab.ca"
]                               

default["acme"]["dir"] = "https://acme-v02.api.letsencrypt.org/directory"
default["acme"]["email"] = "jpbadger@ucalgary.ca"

# You may have to use a different key server from the pool:
# https://sks-keyservers.net/overview-of-pools.php
default["certbot"]["keyserver"] = "na.pool.sks-keyservers.net"
default["certbot"]["prefix"] = "/opt/src/certbot"

default["pebble"]["repository"] = "https://github.com/letsencrypt/pebble"
default["pebble"]["version"] = "v2.0.2"
