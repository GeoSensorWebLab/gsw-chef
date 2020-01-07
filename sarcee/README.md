# Sarcee Node Cookbook

Sets up a node with:

* Dokku
* Docker
* Nginx
* Custom EOL static pages for GSW Lab
* Automatic Docker cleanup scripts
* Munin for local resource logging

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## sarcee

Include `sarcee` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[sarcee]"
  ]
}
```

## Attributes

Please see the comments in `attributes/default.rb` for more details.

## Data Bags and Items

Data bags will be used to load app names, domains, and secret environment variables. They should be encrypted with a secret file/passphrase and `knife` will handle that for you if you use the `--encrypt` arg.

### Data Bag: `apps`

Sample app:

```json
{
  "id": "abm-portal",
  "enabled": true,
  "domains": [
    "sightings.arcticconnect.org",
    "sightings.arcticconnect.ca",
    "arctic-bio-map.gswlab.ca"
  ],
  "env": {
    "DATABASE_URL": "postgres://host/db",
    "RACK_ENV": "production",
    "RAILS_SERVE_STATIC_FILES": "true"
  }
}
```

**id**: name (without spaces) to use for the Dokku app. Not user-facing.

**enabled**: If false, then Chef will not do anything with this data bag.

**domains**: Array of domains to set for Dokku. Necessary for virtual hosts to work correctly.

**env**: Hash of key-values for the app environment. These will be added to the environment using the Dokku CLI, merging with existing ENV settings.

Sample commands:

```
$ knife data bag create apps abm-portal --encrypt
$ knife data bag edit apps abm-portal --encrypt
```

Sample commands for running in test-kitchen locally:

```
$ knife data bag create apps abm-portal -c .chef/config.rb --encrypt
$ knife data bag edit apps abm-portal -c .chef/config.rb --encrypt
```

### Data Bag: `users`

Users for loading SSH keys with push access to Dokku.

Sample user:

```json
{
  "id": "jpbadger",
  "groups": ["dokku"],
  "ssh_keys": [
    "ssh-rsa ..."
  ]
}
```

Users in the `dokku` group will have their SSH keys added to the keys for Dokku.

### Apps Deployed and Running in 2020

* abm-portal
* arctic-portal
* arctic-scholar-portal
* arctic-web-map-pages
* asw-workbench
* bera-dashboard
* sta-time-vis
* sta-webcam

## License and Authors

James Badger (jpbadger@ucalgary.ca)
