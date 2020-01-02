# `deerfoot` cookbook

Cookbook for setting up a node with WMS/WMTS services:

* Java JRE
* GDAL
* Apache Tomcat
* GeoServer
* tomcat-native
* Map source data from various sources

Configuration of layers in GeoServer must be done **manually** after the chef-client run.

### OPTIONAL Manual Configuration

I recommend setting up a cloud volume with ZFS for the map data and tiles under `/srv/data` and `/srv/data/tiles`. Otherwise you may run out of inodes (too many files). On Ubuntu 18.04, the package for ZFS is `zfsutils-linux`.

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## deerfoot

Include `deerfoot` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[deerfoot]"
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
    <td><tt>['deerfoot']['property']</tt></td>
    <td>String</td>
    <td>Description</td>
    <td><tt>default value</tt></td>
  </tr>
</table>

## License and Authors

James Badger (jpbadger@ucalgary.ca)
