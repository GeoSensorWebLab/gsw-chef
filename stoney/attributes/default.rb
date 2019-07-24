# Virtual host definitions for this proxy server.
# If `ssl_enabled` is true, then an HTTPS cert will be requested from
# Let's Encrypt for each domain in `domains`.
default["stoney"]["vhosts"] = [{
  "id"          => "arctic-scholar",
  "domains"     => ["scholar.arcticconnect.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "macleod.gswlab.ca",
  "proxy_port"  => 80
}]
