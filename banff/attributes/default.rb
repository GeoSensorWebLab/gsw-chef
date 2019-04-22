default["banff"]["https_domains"] = [
  # "tiles.arcticconnect.ca",
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
