# GSW Chef Repo

[Chef][] repository for [GeoSensorWeb Lab][gswlab], [University of Calgary][ucalgary].

Contains cookbooks for provisioning machines with various services managed by the GeoSensorWeb Lab. I am planning to include support for Chef-zero to bootstrap servers individually, and to support a centralized Chef server.

Sensitive information such as passwords and keys will be managed externally, and will be manually deployed to servers or via encrypted data bags.

[Chef]: https://www.chef.sh
[gswlab]: https://geosensorweblab.github.io
[ucalgary]: https://www.ucalgary.ca

## Cookbooks Overview

About the names: cloud instances are named after ["trail" roads][roads] in Calgary, Canada.

[roads]: https://en.wikipedia.org/wiki/Category:Roads_in_Calgary

### `gsw-cookbook-template`

Template for new cookbooks. Contains test-kitchen configuration for local testing with VirtualBox/vagrant.

## Bootstrapping Instructions

Want to set up a new/existing cloud instance or machine with a cookbook? Here are the step-by-step instructions. (TODO)

## Why a Monolithic Repo

These cookbooks *could* have been separated into individual git repositories. I chose not to as there is only one sys admin/developer (me) at the moment and one repository is less overhead.

## License

See each cookbook for individual licensing. *If* no license is specified, then Apache 2.0 is assumed.

## Authors

James Badger (@openfirmware, jpbadger@ucalgary.ca)
