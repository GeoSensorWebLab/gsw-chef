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

## Data Bags

Data bags will be used to load app names, domains, and secret environment variables. They should be encrypted with a secret file/passphrase and `knife` will handle that for you if you use the `--encrypt` arg.

### Folder: `apps`

Sample app:

```json
{
  "id": "abm-portal",
  "domains": [
    "sightings.arcticconnect.org",
    "sightings.arcticconnect.ca",
    "arctic-bio-map.gswlab.ca"
  ]
}
```

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

## License and Authors

James Badger (jpbadger@ucalgary.ca)
