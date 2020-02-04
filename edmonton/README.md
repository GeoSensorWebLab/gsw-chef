# `edmonton` cookbook

Cookbook for setting up a node with vector tile servers:

* Munin
* ZFS
* PostgreSQL/PostGIS
* OpenStreetMap Extracts
* Java, Tomcat
* GeoServer
* Node.js
* TileStrata
* Mapnik
* Apache, `mod_tile`

## Supported Platforms

* Ubuntu Server 18.04 LTS

## Usage

## `edmonton::default` recipe

Installs Munin for resource monitoring, and ZFS for storing databases and tile caches. The ZFS Pool must be manually configured as there doesn't seem to be a way to "auto-detect" attached volumes in vagrant virtual machines. This can be done with the `zpool` command:

```
$ sudo zpool create tiledb /dev/sdb
$ sudo zfs create tiledb/postgresql
$ sudo zfs create tiledb/tiles
```

In the above example, a volume mounted at `/dev/sdb` is used as the zpool. Then two volumes are created for snapshot purposes at `/tiledb/postgresql` and `/tiledb/tiles`.

## `edmonton::postgresql` recipe

Installs PostgreSQL with PostGIS and imports an OpenStreetMap extract into multiple databases (one for each projection: `EPSG:4326`, `EPSG:3857`, `EPSG:3573`).

## `edmonton::geoserver` recipe

Installs Java JRE, Apache Tomcat, GeoServer with vector tile plugins. Will automatically pre-configure GeoServer using its REST API.

## `edmonton::tilestrata` recipe

Installs Node.js and requirements for TileStrata.

## `edmonton::mapnik` recipe

Installs Apache, `mod_tile`, Mapnik, and necessary components for Mapnik Vector Tiles.

## Attributes

Attributes are documented in the `attributes` directory.

## License and Authors

James Badger (jpbadger@ucalgary.ca)