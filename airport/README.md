# `airport` cookbook

Cookbook for setting up a node with web map generation services:

* PostgreSQL and PostGIS
* Apache 2 with mod_tile/renderd
* Default OpenStreetMap stylesheet
* Arctic Web Map stylesheet v2.0
* Munin (https://monitoring.gswlab.ca/munin/)
* Munin Node
* Local-only NTP service for clock synchronization

Mapping setup provided using ["maps server"](https://github.com/openfirmware/maps_server) cookbook.

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## airport

Include `airport` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[airport]"
  ]
}
```

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['airport']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
