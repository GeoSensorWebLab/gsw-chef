# GeoServer Documentation

TODO: This document will explain how to set up GeoServer manually after using Chef to install the software.

* Copy rasters/vectors to server
* Set up admin account
* Configure server metadata
* Importing data as "Stores"
* Setting up layers
* Importing SLD and CSS stylesheets
* GeoWebCache setup
* Optimizations for production

## First Steps

I would recommend starting with creating a new cloud server (in OpenStack or EC2) with the average hardware requirements: 2 CPUs, 4 GB of RAM, 30 GB of free disk space.

If you exceed these requirements, then you can modify `attributes/default.rb` to increase the `jobs` and RAM allocated to Apache Tomcat. The install should proceed fine without adjusting these too, it will just be a bit slower to set up.

After creating a new cloud instance or server with Ubuntu Server 18.04 LTS, it must be bootstrapped with Chef to install the basic set of software (see README.markdown for an overview).

I am using Chef Server on a separate cloud server, so my `knife` configuration is using that Chef Server as the cookbook/attribute database instead of Chef Zero. I bootstrapped this server with the following command:

```terminal
$ /usr/local/bin/knife bootstrap deerfoot -N deerfoot --ssh-user ubuntu --sudo --run-list 'recipe[deerfoot]'
```

This will take a few minutes to set up, and will print out any errors.

### Possible Issues

**Cannot download source files that no longer exist:** the default attributes file needs to be updated with the correct URL.

## Accessing GeoServer

Once Chef has ran, a web server should be running on port `8080`. Access the public IPv4/IPv6 URL for your server and use the path for GeoServer:

```
http://192.168.33.10:8080/geoserver
http://[]:8080/geoserver
```

You should see the GeoServer setup page. Follow the instructions and set a strong master password and admin account password. I **strongly** recommend saving these passwords in a [digital password manager][1].

[1]: https://www.pcmag.com/roundup/300318/the-best-password-managers

### HTTPS Support

I have HTTPS set up on a separate cloud server (`stoney`), which then uses HAProxy to redirect requests over HTTP to `deerfoot` on a private network. Requests to port 80 on `stoney` are proxied to port `8080` on `deerfoot`; TLS requests to port 443 on `stoney` are proxied to port `8443` on `deerfoot`. DNS settings in Amazon Route 53 point the domain to `stoney`.

## GeoServer Configuration

### Styles

By default, GeoServer includes some sample layers, styles, and data stores. I recommend deleting them to remove the clutter; only the basic default styles should be kept:

* dem
* generic
* line
* point
* polygon
* raster

These default styles will be used for layers when they are initially created, but we will be installing a custom style for each layer.

### Server Status

Under the "Modules" tab, there should be an entry for the extensions that Chef installed:

* "ImageI/O-Ext GDAL Coverage Extension"

If this is not shown, then you may have to manually restart Tomcat on the server:

```terminal
$ sudo systemctl restart tomcat
```

### Contact Information

Fill out the **Primary Contact** and **Address** information for the server, using the University of Calgary as the location. The OGC Web Services ran by GeoServer will use this information as the administrative contact for their Capabilities documents.

### Services: WCS

Disable WCS, as it is not used for this project.

### Services: WMS

Leave WMS enabled, and fill out the service metadata.

```
Maintainer:         https://github.com/geosensorweblab
Online Resource:    https://github.com/geosensorweblab
Title:              ArcticConnect Web Map Service
Abstract:
Web Map Service for Arctic Institute of North America. Managed by GeoSensorWeb Lab at the University of Calgary.

Fees:               NONE
Access Constraints: NONE

Default Interpolation:  Nearest Neighbor
Max rendering memory:   512000
Max rendering time:     300
```

### Services: WMTS

Leave WMTS enabled. Use the same service metadata as for WMS, switching out references to "Web Map Service" with "Web Map Tile Service".

### Services: WFS

Disable WFS for now. Providing vector data is not a part of the project, currently.

### Settings: Global

The default settings are adequate.

### Settings: Image Processing

```
Memory Capacity:            75%
Memory Threshold:           75%
Tile Threads:               2
Tile Threads Priority:      5
PNG Encoder:                PNGJ based encoder
JPEG Native Acceleration:   Enabled
```

Increase `Tile Threads` if you have more CPUs.

### Settings: Raster Access

```
ImageIO cache memory threshold:     262144
Core pool size:                     2
Maximum pool size:                  5
```

Increase `pool size` values if you have more CPUs.

### Tile Caching: Caching Defaults

Turn off **all** the options, we will do the WMS/WMTS GeoWebCache configuration manually. I recommend leaving it off until we know the basic WMS is working properly, as caching can make debugging some issues very time consuming.

### Security: Settings

Set the "Password encryption" to "Strong PBE". This used to require a special package to be installed for older versions of the JRE but modern versions of OpenJDK include it by default.

### Workspaces

### Styles

### Uploading Datasets

### Stores

### Layers

## TODO: Caching Configuration

TODO: Set up of Gridsets, Blob Store, Disk Quota, tile layer configurations, pre-generation of tiles, testing
