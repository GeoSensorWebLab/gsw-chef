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
# I recommend keeping this array sorted by names.
default['icinga2']['service_objects'] = [
{
  name: "portal.arcticconnect.ca",
  host_name: "sarcee",
  display_name: "ArcticConnect Portal",
  check_command: "http",
  check_interval: "600s",
  retry_interval: "600s",
  groups: [],
  vars: {
    "http_address" => "portal.arcticconnect.ca",
    "http_vhost"   => "portal.arcticconnect.ca"
  }
}
]
