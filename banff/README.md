# `banff` Cookbook

Cookbook for setting up a node with web map generation services:

* Nginx reverse caching proxy
* Let's Encrypt certificates

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

Include `banff` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[banff]"
  ]
}
```

### `banff` recipe

Sets up the node with Nginx for a reverse proxy to one or more upstream tile servers (hard-coded).

Installs `certbot-auto` to automate certificates from "Let's Encrypt". This is needed to provide tiles under HTTPS, which browsers require for some geo-location features.

### `acme_server` recipe

This recipe is for testing locally only with Test Kitchen. The recipe will install Docker and set up a container running [`pebble`][1]. Do not use this in production!

[1]: https://github.com/letsencrypt/pebble

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['banff']['https_domains']</tt></td>
    <td>Array (String)</td>
    <td>List of domains for which to request certificates from "Let's Encrypt". The DNS for these domains <strong>must</strong> point to this server.</td>
    <td><tt>["arctic-web-map-tiles.gswlab.ca"]</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
