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

Installs Munin for resource monitoring, and ZFS for storing databases and tile caches.

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
