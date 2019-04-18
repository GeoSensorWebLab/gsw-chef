default[:users] = ["ubuntu"]
default[:banff][:https_domains] = [
  # "tiles.arcticconnect.ca",
  # "tiles.arcticconnect.org",
  "arctic-web-map-tiles.gswlab.ca"
]                               

# ACME
default[:acme][:contact] = "mailto:jamesbadger@gmail.com"
default[:acme][:endpoint] = "https://acme-v01.api.letsencrypt.org"
default[:acme][:renew] = 30
default[:acme][:private_key] = nil
