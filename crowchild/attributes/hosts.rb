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
  address: "10.1.11.170",
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
  name: "deerfoot",
  address: "10.1.6.106",
  address6: "2605:fd00:4:1000:f816:3eff:fe63:b394",
  groups: ["arcticconnect"],
  check_command: "hostalive"
},
{
  name: "macleod",
  address: "10.1.0.186",
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
  address: "10.1.0.111",
  address6: "2605:fd00:4:1000:f816:3eff:fe17:ad18",
  groups: ["geocens"],
  check_command: "hostalive"
}
]
