# Hostsfile entries.
# These are used for having a shorthand domain that can be used in vhost
# definitions, and so that changes to IPs can be updated in one
# location.
default["gsw-hostsfile"]["hostsfile"] = [
  {
    "hostname" => "airport.gswlab.ca",
    "ip"       => "10.1.14.229"
  },
  {
    "hostname" => "barlow.gswlab.ca",
    "ip"       => "10.1.11.170"
  },
  {
    "hostname" => "beddington.gswlab.ca",
    "ip"       => "10.1.6.127"
  },
  {
    "hostname" => "blackfoot.gswlab.ca",
    "ip"       => "10.1.3.111"
  },
  {
    "hostname" => "bow.gswlab.ca",
    "ip"       => "10.1.4.6"
  },
  {
    "hostname" => "cowboy.gswlab.ca",
    "ip"       => "10.1.9.179"
  },
  {
    "hostname" => "crowchild.gswlab.ca",
    "ip"       => "10.1.10.243"
  },
  {
    "hostname" => "deerfoot.gswlab.ca",
    "ip"       => "10.1.6.106"
  },
  {
    "hostname" => "macleod.gswlab.ca",
    "ip"       => "10.1.0.186"
  },
  {
    "hostname" => "sarcee.gswlab.ca",
    "ip"       => "10.1.11.237"
  },
  {
    "hostname" => "shaganappi.gswlab.ca",
    "ip"       => "10.1.0.158"
  },
  {
    "hostname" => "stoney.gswlab.ca",
    "ip"       => "10.1.0.111"
  }
]
