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

## Creating New Cookbooks

1. Duplicate the template: `cp -r gsw-cookbook-template node-cookbook`
2. Edit `node-cookbook` to replace `gsw-cookbook-template` in recipes, metadata, etc
3. Add `node-cookbook` to the git repository and push to origin

## Bootstrapping Instructions

Want to set up a new/existing cloud instance or machine with a cookbook? Here are the step-by-step instructions. (TODO)

For Knife, be sure to add configuration settings for Chef Vault:

```rb
knife[:vault_mode] = "client"
```

## Setting Up a Chef Server

As an alternative to bootstrapping cookbooks, a centralized Chef Server can be used to manage node attributes and run lists, as well as data bags. See the [Chef Server Cookbook](gsw-chef-server/README.md) for details.

## Why a Monolithic Repo

These cookbooks *could* have been separated into individual git repositories. I chose not to as there is only one sys admin/developer (me) at the moment and one repository is less overhead.

## Why I Avoid SuperMarket Cookbooks

Chef SuperMarket has many publicly available cookbooks that can be re-used for great functionality. Unfortunately many are out of date and barely supported or even abandoned. Some may not support more recent OS releases, or work with the latest version of Chef. Some of the maintainers have moved on to other projects, or are no longer employed at the same company/organization. Sometimes major releases have major API changes that I don't have time to implement.

For those reasons I have found it easier to install and configure software in your own cookbooks, especially for really small teams. This also means new developers will not have to look up external cookbook APIs to understand what a cookbook in this repository is doing.

## License

See each cookbook for individual licensing. *If* no license is specified, then Apache 2.0 is assumed.

## Authors

James Badger (@openfirmware, jpbadger@ucalgary.ca)
