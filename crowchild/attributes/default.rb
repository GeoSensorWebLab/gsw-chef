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
