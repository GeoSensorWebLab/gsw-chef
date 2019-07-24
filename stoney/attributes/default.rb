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
  "domains"     => ["scholar.arcticconnect.ca"],
  "ssl_enabled" => false,
  "proxy_host"  => "macleod.gswlab.ca",
  "proxy_port"  => 80
}]
