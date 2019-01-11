default['crowchild']['https_admin_email'] = "jpbadger@ucalgary.ca"
default['crowchild']['ignore_real_certs'] = false

# Host Definitions for Icinga2
# 
# Sample Host:
#   name: string, mandatory
#   address: string, optional
#   address6: string, optional
#   groups: array of strings, optional
#   check_command: string, mandatory
#
# I recommend keeping this array sorted by names.
default['icinga2']['host_objects'] = [
{
  name: "banff",
  address: "199.116.235.84",
  address6: "2605:fd00:4:1000:f816:3eff:feac:7e73",
  groups: ["arcticconnect"],
  check_command: "hostalive"
},
{
  name: "barlow",
  address: "162.246.156.221",
  address6: "2605:fd00:4:1000:f816:3eff:fe7c:7c2a",
  groups: ["arcticconnect"],
  check_command: "hostalive"
},
{
  name: "blackfoot",
  address: "10.1.11.89",
  address6: "2605:fd00:4:1000:f816:3eff:fe2d:6f0e",
  groups: ["arcticconnect"],
  check_command: "hostalive"
},
{
  name: "bow",
  address: "162.246.156.118",
  address6: "2605:fd00:4:1000:f816:3eff:fe83:3438",
  groups: ["arcticconnect"],
  check_command: "hostalive"
},
{
  name: "crowchild",
  address: "162.246.156.119",
  address6: "2605:fd00:4:1000:f816:3eff:feeb:5155",
  groups: ["geocens"],
  check_command: "hostalive"
},
{
  name: "ctscience",
  address: "10.1.0.194",
  address6: "2605:fd00:4:1000:f816:3eff:feb4:809e",
  groups: ["geocens"],
  check_command: "hostalive"
},
{
  name: "glenmore",
  address: "10.1.0.250",
  address6: "2605:fd00:4:1000:f816:3eff:fef4:fdd9",
  groups: ["geocens"],
  check_command: "hostalive"
},
{
  name: "macleod",
  address: "199.116.235.109",
  address6: "2605:fd00:4:1000:f816:3eff:fe83:4b52",
  groups: ["geocens"],
  check_command: "hostalive"
},
{
  name: "sarcee",
  address: "10.1.11.237",
  address6: "2605:fd00:4:1000:f816:3eff:fee6:b246",
  groups: ["arcticconnect"],
  check_command: "hostalive"
},
{
  name: "shaganappi",
  address: "10.1.0.158",
  address6: "2605:fd00:4:1000:f816:3eff:fe9e:b42f",
  groups: ["geocens"],
  check_command: "hostalive"
},
{
  name: "stoney",
  address: "199.116.235.80",
  address6: "2605:fd00:4:1000:f816:3eff:fee4:ecae",
  groups: ["geocens"],
  check_command: "hostalive"
}
]

# Service Definitions for Icinga2
# 
# Sample Host:
#   name (string, mandatory) icinga2 object name
#   host_name (string, mandatory) icinga2 host this service belongs to
#   display_name (string, mandatory) icinga2 UI display name
#   check_command (string, mandatory) icinga2 check command to use
#   check_interval (duration string, mandatory) Check interval with `s`
#       suffix
#   retry_interval (duration string, mandatory) Retry interval with `s`
#       suffix
#   groups: (array of strings, optional)
#   vars: (hash, optional) Hash of key/value pairs for "vars" in an 
#       object. All values will be double-quoted.
#   
# I recommend keeping this array sorted by category, then by names.
# Categories:
# * HTTP
# * HTTPS
default['icinga2']['service_objects'] = [
# HTTP Services
{
  name: "arcticconnect.ca",
  host_name: "sarcee",
  display_name: "Arctic Connect Landing Page",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "arcticconnect.ca",
    "http_vhost"   => "arcticconnect.ca"
  }
},
{
  name: "aafc.gswlab.ca",
  host_name: "sarcee",
  display_name: "AAFC Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "aafc.gswlab.ca",
    "http_vhost"   => "aafc.gswlab.ca"
  }
},
{
  name: "chef.gswlab.ca",
  host_name: "sarcee",
  display_name: "GSWLab Chef Server",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "chef.gswlab.ca",
    "http_vhost"   => "chef.gswlab.ca"
  }
},
{
  name: "dataservice.gswlab.ca",
  host_name: "sarcee",
  display_name: "Data Service",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "dataservice.gswlab.ca",
    "http_vhost"   => "dataservice.gswlab.ca"
  }
},
{
  name: "dataservice-web.gswlab.ca",
  host_name: "sarcee",
  display_name: "Data Service Proxy",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "dataservice-web.gswlab.ca",
    "http_vhost"   => "dataservice-web.gswlab.ca"
  }
},
{
  name: "geocens.gswlab.ca",
  host_name: "sarcee",
  display_name: "GeoCENS Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "geocens.gswlab.ca",
    "http_vhost"   => "geocens.gswlab.ca"
  }
},
{
  name: "eaglewatch.gswlab.ca",
  host_name: "sarcee",
  display_name: "Eagle Watch Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "eaglewatch.gswlab.ca",
    "http_vhost"   => "eaglewatch.gswlab.ca"
  }
},
{
  name: "errbit.gswlab.ca",
  host_name: "sarcee",
  display_name: "Errbit",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "errbit.gswlab.ca",
    "http_vhost"   => "errbit.gswlab.ca"
  }
},
{
  name: "ows-search.gswlab.ca",
  host_name: "sarcee",
  display_name: "OGC Web Services search",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "ows-search.gswlab.ca",
    "http_vhost"   => "ows-search.gswlab.ca"
  }
},
{
  name: "portal.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "ArcticConnect Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "portal.arcticconnect.ca",
    "http_vhost"   => "portal.arcticconnect.ca"
  }
},
{
  name: "records.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "Arctic Scholar Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "records.arcticconnect.ca",
    "http_vhost"   => "records.arcticconnect.ca"
  }
},
{
  name: "rockyview.gswlab.ca",
  host_name: "sarcee",
  display_name: "RVC Redirect",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "rockyview.gswlab.ca",
    "http_vhost"   => "rockyview.gswlab.ca"
  }
},
{
  name: "scholar.arcticconnect.ca",
  host_name: "macleod",
  display_name: "Arctic Scholar API",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "scholar.arcticconnect.ca",
    "http_vhost"   => "scholar.arcticconnect.ca"
  }
},
{
  name: "sensors.arcticconnect.ca",
  host_name: "blackfoot",
  display_name: "Arctic Sensor Web Expansion",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "sensors.arcticconnect.ca",
    "http_vhost"   => "sensors.arcticconnect.ca"
  }
},
{
  name: "sensorweb.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "Arctic Sensor Web",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "sensorweb.arcticconnect.ca",
    "http_vhost"   => "sensorweb.arcticconnect.ca"
  }
},
{
  name: "sightings.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "Arctic Bio Map Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "sightings.arcticconnect.ca",
    "http_vhost"   => "sightings.arcticconnect.ca"
  }
},
{
  name: "visualize.gswlab.ca",
  host_name: "sarcee",
  display_name: "STA Visualization",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "visualize.gswlab.ca",
    "http_vhost"   => "visualize.gswlab.ca"
  }
},
{
  name: "webmap.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "Arctic Web Map",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "webmap.arcticconnect.ca",
    "http_vhost"   => "webmap.arcticconnect.ca"
  }
},
{
  name: "workbench.gswlab.ca",
  host_name: "sarcee",
  display_name: "RPI Workbench",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "workbench.gswlab.ca",
    "http_vhost"   => "workbench.gswlab.ca"
  }
},

# HTTPS Services
{
  name: "https-chef.gswlab.ca",
  host_name: "sarcee",
  display_name: "https-HTTPS GSWLab Chef Server",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: [],
  vars: {
    "http_address" => "chef.gswlab.ca",
    "http_vhost"   => "chef.gswlab.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-portal.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "https-HTTPS ArcticConnect Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "portal.arcticconnect.ca",
    "http_vhost"   => "portal.arcticconnect.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-records.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "https-HTTPS Arctic Scholar Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "records.arcticconnect.ca",
    "http_vhost"   => "records.arcticconnect.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-scholar.arcticconnect.ca",
  host_name: "macleod",
  display_name: "https-HTTPS Arctic Scholar API",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "scholar.arcticconnect.ca",
    "http_vhost"   => "scholar.arcticconnect.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-sensors.arcticconnect.ca",
  host_name: "blackfoot",
  display_name: "https-HTTPS Arctic Sensor Web Expansion",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "sensors.arcticconnect.ca",
    "http_vhost"   => "sensors.arcticconnect.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-sensorweb.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "https-HTTPS Arctic Sensor Web",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "sensorweb.arcticconnect.ca",
    "http_vhost"   => "sensorweb.arcticconnect.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-sightings.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "https-HTTPS Arctic Bio Map Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "sightings.arcticconnect.ca",
    "http_vhost"   => "sightings.arcticconnect.ca",
    "http_ssl"     => true
  }
},
{
  name: "https-webmap.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "https-HTTPS Arctic Web Map",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "webmap.arcticconnect.ca",
    "http_vhost"   => "webmap.arcticconnect.ca",
    "http_ssl"     => true
  }
}
]
