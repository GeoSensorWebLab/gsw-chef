default['crowchild']['https_admin_email'] = "jpbadger@ucalgary.ca"
default['crowchild']['ignore_real_certs'] = false

default['icinga2']['plugins_directory'] = '/usr/lib/nagios/plugins'

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
  name: "airport",
  address: "10.1.14.229",
  address6: "2605:fd00:4:1000:f816:3eff:fe37:c7b3",
  groups: ["geocens"],
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
  address: "10.1.3.111",
  address6: "2605:fd00:4:1000:f816:3eff:fec5:a91d",
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
  name: "ctscience",
  address: "10.1.0.194",
  address6: "2605:fd00:4:1000:f816:3eff:feb4:809e",
  groups: ["geocens"],
  check_command: "hostalive"
},
{
  name: "deerfoot",
  address: "10.1.6.106",
  address6: "2605:fd00:4:1000:f816:3eff:fe63:b394",
  groups: ["arcticconnect"],
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
  address6: "2605:fd00:4:1000:f816:3eff:fe17:ad18",
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
# * SSL
# * Domain Expiration
default['icinga2']['service_objects'] = [
#########################
# HTTP Services Section #
#########################
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
  host_name: "stoney",
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
##########################
# HTTPS Services Section #
##########################
{
  name: "https-chef.gswlab.ca",
  host_name: "barlow",
  display_name: "HTTPS GSWLab Chef Server",
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
  display_name: "HTTPS ArcticConnect Portal",
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
  display_name: "HTTPS Arctic Scholar Portal",
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
  host_name: "stoney",
  display_name: "HTTPS Arctic Sensor Web Expansion",
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
  display_name: "HTTPS Arctic Sensor Web",
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
  display_name: "HTTPS Arctic Bio Map Portal",
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
  display_name: "HTTPS Arctic Web Map",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "300s",
  groups: ["arcticconnect"],
  vars: {
    "http_address" => "webmap.arcticconnect.ca",
    "http_vhost"   => "webmap.arcticconnect.ca",
    "http_ssl"     => true
  }
},
###############
# SSL Section #
###############
{
  name: "ssl-chef.gswlab.ca",
  host_name: "barlow",
  display_name: "GSWLab Chef Server Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: [],
  vars: {
    "ssl_address"                  => "chef.gswlab.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-portal.arcticconnect.ca",
  host_name: "stoney",
  display_name: "ArcticConnect Portal Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "portal.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-records.arcticconnect.ca",
  host_name: "stoney",
  display_name: "Arctic Scholar Portal Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "records.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-scholar.arcticconnect.ca",
  host_name: "macleod",
  display_name: "Arctic Scholar API Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "scholar.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-sensors.arcticconnect.ca",
  host_name: "stoney",
  display_name: "Arctic Sensor Web Expansion Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "sensors.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-sensorweb.arcticconnect.ca",
  host_name: "stoney",
  display_name: "Arctic Sensor Web Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "sensorweb.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-sightings.arcticconnect.ca",
  host_name: "stoney",
  display_name: "Arctic Bio Map Portal Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "sightings.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
{
  name: "ssl-webmap.arcticconnect.ca",
  host_name: "stoney",
  display_name: "Arctic Web Map Certificate",
  check_command: "ssl",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "ssl_address"                  => "webmap.arcticconnect.ca",
    "ssl_cert_valid_days_warn"     => "25",
    "ssl_cert_valid_days_critical" => "10",
    "ssl_timeout"                  => "20"
  }
},
#############################
# Domain Expiration Section #
#############################
{
  name: "arcticconnect.ca domain",
  host_name: "stoney",
  display_name: "ArcticConnect.ca Domain",
  check_command: "domain_expiration",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "domain_check"    => "arcticconnect.ca",
    "domain_warning"  => "30",
    "domain_critical" => "10"
  }
},
{
  name: "gswlab.ca domain",
  host_name: "stoney",
  display_name: "GSWLab.ca Domain",
  check_command: "domain_expiration",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: [],
  vars: {
    "domain_check"    => "gswlab.ca",
    "domain_warning"  => "30",
    "domain_critical" => "10"
  }
},
{
  name: "arcticconnect.org domain",
  host_name: "stoney",
  display_name: "ArcticConnect.org Domain",
  check_command: "domain_expiration",
  check_interval: "86400s",
  retry_interval: "86400s",
  groups: ["arcticconnect"],
  vars: {
    "domain_check"    => "arcticconnect.org",
    "domain_warning"  => "30",
    "domain_critical" => "10"
  }
},
]
