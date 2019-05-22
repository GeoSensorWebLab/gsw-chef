# GeoServer Documentation

TODO: This document will explain how to set up GeoServer manually after using Chef to install the software.

* Importing data as "Stores"
* Setting up layers
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

Create a new workspace for the project, this will be used to group layers/styles/etc.

```
Name:           arcticconnect
Namespace URI:  http://arcticconnect.ca
Default Workspace Enabled
Isolated Workspace Disabled
```

### Styles

The default GeoServer styles will be trimmed to remove styles we are not using for this project. This is done automatically by Chef.

For each SLD file in `files/default/styles`, create a new style in the `arcticconnect` workspace with `SLD` format. Name the style after the filename (without extension), pasting in the XML contents for the style.

For each CSS file in `files/default/styles`, create a new style in the `arcticconnect` workspace with `CSS` format. Name the style after the filename (without extension), pasting in the CSS contents for the style.

### Uploading Datasets

Please see the `DATA_PREPARATION.markdown` document for instructions on preparing and processing the data from the source files into formats for this project.

Upload the following data files to the server:

* `background.gpkg`
* `cgn_canada_eng.gpkg`
* `coastline.gpkg`
* `glaciers.gpkg`
* `hydrography_lakes.gpkg`
* `hydrography_rivers.gpkg`
* `ne_10m_bathymetry_all.gpkg`
* `ne_10m_graticules_15.gpkg`
* `arcticdem_500m_3413.tif`
* `arcticdem_500m_3413_hillshade.tif`
* `arcticdem_500m_3413_slope.tif`
* `arcticdem_500m_4326.tif`
* `arcticdem_500m_4326_hillshade.tif`
* `arcticdem_500m_4326_slope.tif`
* `soper_map_3413.tif`
* `soper_map.tif`

**Important:** Place these files in a directory accessible by the `tomcat` user, and change the ownership of the files (AND the enclosing folder) to `tomcat` so that GeoPackages are correctly read by Java.

(While it is possible to upload only some of these files to the server and run GDAL there, it is faster to run GDAL locally on your development machine and verify the results *before* uploading.)

### Stores: Vector Data

For each vector data source, create a new `Store` with vector data type `GeoPackage`. You only need to fill out `Data Source Name` (the filename), and `database` (the path to the GeoPackage on the server). You can click "Browse…" to manually browse the filesystem on the server to find the `.gpkg` file.

After creating the `Store`, GeoServer will prompt you to publish a layer for the store. Go ahead and "Publish", which will open the "Layer" form. Most of the following data can be filled out based on the details in `DATA_PREPARATION.markdown`.

The "Name" is the machine-readable name of the layer; keep it simple and lowercase.

Make sure the layer is "Enabled" so that we can use it in a Layer Group later. **Disable** advertising the layer, as we do not want to offer it on WMS/WMTS as its own layer.

The "Title" is the human-readable name; keep it simple and grammatically correct.

The "Abstract" is a short description of the layer and should credit any data sources and copyrights.

Ignore "Keywords", "Vocabulary", "Metadata links", "Data links".

Leave the "Native SRS" and "Declared SRS" as default. If "Declared SRS" is empty, click "Find" (or "…") to open a dialog box; type in "4326" and select EPSG:4326 in the results to force that SRS. Leave "SRS handling" at the default value.

For "Native Bounding Box", click "Compute from data". For "Lat/Lon Bounding Box", click "Compute from native bounds".

For "Restrict the features on layer by CQL filter" please refer to the data source details in `DATA_PREPARATION`. This field may be necessary to remove extraneous data before rendering.

Next, click the "Publishing" tab. You do not need to "Save" before switching tabs; that is done automatically.

Under "WMS Settings" for "Publishing", change the "Default Style" to the style for that layer; it should have the same name as the dataset filename.

Click "Save", and continue adding the rest of the vector data sources as Stores/Layers.

### Stores: Raster Data

Adding raster data is similar as to vector data, with a few minor differences due to the formats.

Under the "Stores" page, add a new store for each `TIF` file using "GeoTIFF" as the raster data type. You will only need to fill out `Data Source Name` (the filename), and `URL` (the path to the GeoTIFF on the server).

After creating the Store, GeoServer will ask you to publish a layer for the store; go ahead and do that. This will open the New Layer form.

The "Name" is the machine-readable name of the layer; keep it simple and lowercase.

Make sure the layer is "Enabled" so that we can use it in a Layer Group later. **Disable** advertising the layer, as we do not want to offer it on WMS/WMTS as its own layer.

The "Title" is the human-readable name; keep it simple and grammatically correct.

The "Abstract" is a short description of the layer and should credit any data sources and copyrights.

Ignore "Keywords", "Vocabulary", "Metadata links", "Data links".

Leave the "Native SRS" and "Declared SRS" as default. If either field is **empty**, then there is something wrong with the GeoTIFF — delete the Layer, Store, and re-process the GeoTIFF file.

For "Native Bounding Box", click "Compute from data". For "Lat/Lon Bounding Box", click "Compute from native bounds".

**Safety Check:** under "Coverage Band Details", ensure the "Data type" is *not* `Real 32 bits` — there is a bug in GeoServer that causes these raster to not properly render, and you will get very cryptic errors. If you see this data type, then the file will need to be re-processed properly to change the data type.

Next, click the "Publishing" tab. You do not need to "Save" before switching tabs; that is done automatically.

Under "WMS Settings" for "Publishing", change the "Default Style" to the style for that layer; it should have the same name as the dataset filename.

Click "Save", and continue adding the rest of the raster data sources as Stores/Layers.

### Layer Groups

## TODO: Caching Configuration

TODO: Set up of Gridsets, Blob Store, Disk Quota, tile layer configurations, pre-generation of tiles, testing
