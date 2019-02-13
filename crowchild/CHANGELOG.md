# Changelog for crowchild

## v0.3.1

* Do not do a host check on self for Icinga 2
* Add a plugin to check expiration of domain names
* Mark some Chef directives as sensitive to prevent logging
* Query certain nodes for munin data

## v0.3.0

* Put munin and icinga web 2 under same domain virtual host
* Install munin and munin-node
* Fix excessive certificate requests
* Install NTP for time synchronization
* Load Icinga2 Host objects from cookbook
* Load Icinga2 Group objects from cookbook
* Load Icinga2 Service objects from cookbook
* Enable command transport in Icinga Web 2

## v0.2.0

* Install HTTPS certificates for monitoring.gswlab.ca and monitoring.arcticconnect.ca using Let's Encrypt

## v0.1.0

* Initial release
* Installs and configures Icinga 2, Icinga 2 Web UI
