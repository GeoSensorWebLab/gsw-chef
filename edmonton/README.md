# `edmonton` cookbook

Cookbook for setting up a node with vector tile servers:

* Munin
* ZFS
* PostgreSQL 12/PostGIS
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
$ sudo zfs set recordsize=8K tiledb/postgresql
$ sudo zfs set atime=off tiledb/postgresql
$ sudo zfs set relatime=on tiledb/postgresql
$ sudo zfs set logbias=throughput tiledb/postgresql
$ sudo zfs set xattr=sa tiledb/postgresql
$ sudo zfs set primarycache=metadata tiledb/postgresql
$ sudo zfs create tiledb/tiles
$ sudo zfs create tiledb/geoserver
```

In the above example, a volume mounted at `/dev/sdb` is used as the zpool. Then volumes are created for snapshot purposes. Special options are configured for PostgreSQL performance on that filesystem volume.

## `edmonton::postgresql` recipe

Installs PostgreSQL 12 with PostGIS and imports an OpenStreetMap extract into multiple databases (one for each projection: `EPSG:4326`, `EPSG:3857`, `EPSG:3573`).

`osm2pgsql` is installed from source (v1.2.1) instead of Ubuntu Apt (v0.9.4).

## `edmonton::shapefiles` recipe

Uses GDAL to import shapefiles from different sources into PostGIS databases.

## `edmonton::geoserver` recipe

Installs OpenJDK 13, Apache Tomcat, GeoServer with multiple plugins:

* vector tiles plugin
* GeoCSS plugin

Partial configuration is done with REST API (changing of default passwords), but set up of layers must still be done manually through the web interface.

The GeoServer data directory will be moved onto the ZFS volume at `/tiledb/geoserver` (customizeable in attributes).

The default GeoServer master password will be replaced by the `master_password` defined in Chef Vault or a Data bag. The admin user's password will be replaced with the contents of `password`.

```terminal
$ knife vault create passwords geoserver
{
    "id": "geoserver",
    "master_password": "new_password_here",
    "password": "new_password_here",
}
```

Or using data bags:

```terminal
$ knife data bag create passwords geoserver --secret-file path/to/secret-file
{
    "id": "geoserver",
    "master_password": "new_password_here",
    "password": "new_password_here"
}
```

## `edmonton::tilestrata` recipe

Installs Node.js and requirements for TileStrata.

## `edmonton::mapnik` recipe

Installs Apache, `mod_tile`, Mapnik, and necessary components for Mapnik Vector Tiles.

## Attributes

Attributes are documented in the `attributes` directory.

## License and Authors

James Badger (jpbadger@ucalgary.ca)
