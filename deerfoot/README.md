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

### Tomcat Upgrade Instructions

When upgrading Tomcat, the attributes file must be updated with new version numbers and download URLs. The old version of Tomcat should be manually shut down before running the Chef client, otherwise the new version of Tomcat won't start as the port is already taken. Chef will set up a *separate* installation of Tomcat from the one already on the server, meaning there will be multiple versions. To complete the upgrade, the GeoServer directory in the **old** version of Tomcat's `webapps` directory must be installed into the **new** version of Tomcat's `webapps` directory, replacing the blank GeoServer installed by Chef client. A restart of Tomcat may be necessary.

* Update cookbook with new Tomcat version information
* Upload cookbook to Chef Server
* Stop old Tomcat on node
* Run chef-client on node
* Copy old GeoServer directory into new Tomcat
* Restart Tomcat
* Run chef-client on node to confirm upgrade works
* Optionally, delete old Tomcat/GeoServer installation

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
