# GeoServer Documentation

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
Web Map Service for Arctic Connect platform and related projects. Managed by GeoSensorWeb Lab at the University of Calgary.

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

## Setting up Layers

### Uploading Datasets

Please see the [`3_DATA_PREPARATION.markdown`](3_DATA_PREPARATION.markdown) document for instructions on preparing and processing the data from the source files into formats for this project.

Upload the following data files to the server:

* `background.gpkg`
* `placenames.gpkg`
* `coastline.gpkg`
* `glaciers.gpkg`
* `lakes.gpkg`
* `rivers.gpkg`
* `bathymetry.gpkg`
* `graticules.gpkg`
* `arcticdem_500_3413.tif`
* `arcticdem_500_3413_hillshade.tif`
* `arcticdem_500_3413_slope.tif`
* `arcticdem_500_4326.tif`
* `arcticdem_500_4326_hillshade.tif`
* `arcticdem_500_4326_slope.tif`
* `soper_3413.tif`
* `soper_4326.tif`

**Important:** Place these files in a directory accessible by the `tomcat` user, and change the ownership of the files (AND the enclosing folder) to `tomcat` so that GeoPackages are correctly read by Java.

(While it is possible to upload only some of these files to the server and run GDAL there, it is faster to run GDAL locally on your development machine and verify the results *before* uploading.)

### Stores: Vector Data

For each vector data source, create a new `Store` with vector data type `GeoPackage`. You only need to fill out `Data Source Name` (the filename), and `database` (the path to the GeoPackage on the server). You can click "Browse…" to manually browse the filesystem on the server to find the `.gpkg` file.

After creating the `Store`, GeoServer will prompt you to publish a layer for the store. Go ahead and "Publish", which will open the "Layer" form. Most of the following data can be filled out based on the details in [`4_LAYER_METADATA.markdown`](4_LAYER_METADATA.markdown).

The "Name" is the machine-readable name of the layer; keep it simple and lowercase.

Make sure the layer is "Enabled" so that we can use it in a Layer Group later. **Disable** advertising the layer, as we do not want to offer it on WMS/WMTS as its own layer.

The "Title" is the human-readable name; keep it simple and grammatically correct.

The "Abstract" is a short description of the layer and should credit any data sources and copyrights.

Ignore "Keywords", "Vocabulary", "Metadata links", "Data links".

Leave the "Native SRS" and "Declared SRS" as default. If "Declared SRS" is empty, click "Find" (or "…") to open a dialog box; type in "4326" and select EPSG:4326 in the results to force that SRS. Leave "SRS handling" at the default value.

For "Native Bounding Box", click "Compute from data". For "Lat/Lon Bounding Box", click "Compute from native bounds".

For "Restrict the features on layer by CQL filter" please refer to the data source details in [`4_LAYER_METADATA.markdown`](4_LAYER_METADATA.markdown). This field may be necessary to remove extraneous data before rendering.

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

### Layer Customization: Soper's Map

Soper's Map will be advertised separately, as we want it to be turned on/off separately from the base layer.

Import the raster images as new "Stores", and publish the layers using metadata listed in [`4_LAYER_METADATA.markdown`](4_LAYER_METADATA.markdown). It may be necessary to set the "Declared SRS" to `EPSG:3413` or `EPSG:4326` (depending on the input raster).

Set the layers to NOT be advertised. Instead, create individual layer groups for each projection, adding either the `EPSG:3413` or `EPSG:4326` base raster depending on polar or mercator projection. Using layer groups allows for GeoServer to re-project the image into its own layer, and that layer can have its own gridset tile cache. Otherwise there is no way of accessing a layer's secondary gridset.

### Layer Groups

A "Layer Group" is a set of layers merged together and advertised as a single layer in WMS/WMTS/etc. We will be using this to advertise the base layers in a few different projections:

* `EPSG:3413` a.k.a. [NSIDC Sea Ice Polar Stereographic North](http://epsg.io/3413)
    * `EPSG:3573` a.k.a. [North Pole LAEA Canada](http://epsg.io/3573)
    * `EPSG:3574` a.k.a. [North Pole LAEA Atlantic](http://epsg.io/3574)
    * `EPSG:102002` a.k.a. [Canada Lambert Conformal Conic](http://epsg.io/102002)
* `EPSG:4326` a.k.a. [WGS84](https://epsg.io/4326)
    * `EPSG:3857` a.k.a. [Pseudo-Mercator](https://epsg.io/3857)

`EPSG:3413` is the base for the polar-projected maps, and `EPSG:4326` is the base for the Mercator-projected maps. These are done separately as there can be some weird rendering errors when you let GeoServer do Mercator-to-polar projections on-the-fly.

We offer 3573/3574 for integration with [Arctic Web Map](https://webmap.arcticconnect.ca), which supports these projections.

We offer 3857 for integration with OSM/Bing Maps/Google Maps, although it isn't recommended due to the distortion in the north.

#### Primary Layer Group `EPSG:3413`

Create a new layer group for the `EPSG:3413` base layer. Most of these fields follow the same rules as individual layers.

```
Name:           base_map_3413
Title:          Base Map (EPSG:3413)
Abstract:
Base map for Soper's World project (Arctic Institute of North America).
Uses ArcticDEM at 500m resolution, GSHHG coastline data, Natural Earth Data bathymetry/graticules, Government of Canada North American Atlas Rivers/Lakes/Glaciers, and Canada Geographic Names dataset.

DEMs provided by the Polar Geospatial Center under NSF-OPP awards 1043681, 1559691, and 1542736.

Workspace:                      arcticconnect
Coordinate Reference System:    EPSG:3413
Mode:                           Single
```

Leave "Queryable" enabled, as it allows WMS "GetFeatureInfo" requests.

One-by-one, add the following layers in the following order:

1. `arcticconnect:background`
2. `arcticconnect:bathymetry`
3. `arcticconnect:coastline`
4. `arcticconnect:arcticdem_500m_3413_hillshade`
5. `arcticconnect:arcticdem_500m_3413_slope`
6. `arcticconnect:arcticdem_500m_3413`
7. `arcticconnect:rivers`
8. `arcticconnect:lakes`
9. `arcticconnect:glaciers`
10. `arcticconnect:graticules`
11. `arcticconnect:placenames`

Note that we use the `EPSG:3413` rasters!

Then click the "Generate Bounds" button, which should fill in the "Bounds" fields.

Save the layer.

#### Secondary Polar Layer Groups

For each of the other polar projections, create a new layer group. Here are the sample fields for one:

```
Name:           base_map_3574
Title:          Base Map (EPSG:3574)
Abstract:
Base map for Soper's World project (Arctic Institute of North America).
Uses ArcticDEM at 500m resolution, GSHHG coastline data, Natural Earth Data bathymetry/graticules, Government of Canada North American Atlas Rivers/Lakes/Glaciers, and Canada Geographic Names dataset.

DEMs provided by the Polar Geospatial Center under NSF-OPP awards 1043681, 1559691, and 1542736.

Workspace:                      arcticconnect
Coordinate Reference System:    EPSG:3574
Mode:                           Named Tree
```

Instead of adding each layer one-by-one, add the entire `EPSG:3413` layer group. Generate Bounds and save the layer.

We use `Named Tree` otherwise the parent layer group *disappears* from the WMS layer list. Not sure why.

**Note:** For `EPSG:102002`, manually enter the following bounds as they are not properly generated.

```
Min X:      -5,615,818.3524223
Min Y:      5.141556829724574
Max X:      5,849,324.486082172
Max Y:      11,222,809.102523187
```

#### Primary Layer Group `EPSG:4326`

Create a new layer group for the `EPSG:4326` base layer. Most of these fields follow the same rules as individual layers.

```
Name:           base_map_4326
Title:          Base Map (EPSG:4326)
Abstract:
Base map for Soper's World project (Arctic Institute of North America).
Uses ArcticDEM at 500m resolution, GSHHG coastline data, Natural Earth Data bathymetry/graticules, Government of Canada North American Atlas Rivers/Lakes/Glaciers, and Canada Geographic Names dataset.

DEMs provided by the Polar Geospatial Center under NSF-OPP awards 1043681, 1559691, and 1542736.

Workspace:                      arcticconnect
Coordinate Reference System:    EPSG:4326
Mode:                           Single
```

Leave "Queryable" enabled, as it allows WMS "GetFeatureInfo" requests.

One-by-one, add the following layers in the following order:

1. `arcticconnect:background`
2. `arcticconnect:bathymetry`
3. `arcticconnect:coastline`
4. `arcticconnect:arcticdem_500m_4326_hillshade`
5. `arcticconnect:arcticdem_500m_4326_slope`
6. `arcticconnect:arcticdem_500m_4326`
7. `arcticconnect:rivers`
8. `arcticconnect:lakes`
9. `arcticconnect:glaciers`
10. `arcticconnect:graticules`
11. `arcticconnect:placenames`

Note that we use the `EPSG:4326` rasters!

Then click the "Generate Bounds" button, which should fill in the "Bounds" fields.

Save the layer.

#### Secondary Mercator Layer Groups

For each of the other mercator projections, create a new layer group. Here are the sample fields for one:

```
Name:           base_map_3857
Title:          Base Map (EPSG:3857)
Abstract:
Base map for Soper's World project (Arctic Institute of North America).
Uses ArcticDEM at 500m resolution, GSHHG coastline data, Natural Earth Data bathymetry/graticules, Government of Canada North American Atlas Rivers/Lakes/Glaciers, and Canada Geographic Names dataset.

DEMs provided by the Polar Geospatial Center under NSF-OPP awards 1043681, 1559691, and 1542736.

Workspace:                      arcticconnect
Coordinate Reference System:    EPSG:3857
Mode:                           Named Tree
```

Instead of adding each layer one-by-one, add the entire `EPSG:4326` layer group. Generate Bounds and save the layer.

We use `Named Tree` otherwise the parent layer group *disappears* from the WMS layer list. Not sure why.

## Caching Configuration

Before setting up GeoWebCache, test out the WMS and WMTS services using QGIS as the client. The layers may be slow to load, but as long as they A) load, and B) look correct, then the slow render is fine and will be fixed by setting up caching.

### Gridsets

`EPSG:4326` and `EPSG:3857` (as `EPSG:900913`) are already included by default. Here are the ones to create for caching. Add zoom levels up to "level 12". Beyond that level the map can generate on-the-fly.

```
EPSG:3413
Gridset Bounds:
    Min X:      -12977546.987062823
    Min Y:      -12977546.987062823
    Max X:      12977546.987062823
    Max Y:      12977546.987062823

EPSG:3573
Gridset Bounds: (Computer from maximum extent of CRS)

EPSG:3574
Gridset Bounds: (Computer from maximum extent of CRS)

EPSG:102002
Gridset Bounds:
    Min X:      -5615818.3524223
    Min Y:      5.141556829724574
    Max X:      5849324.486082172
    Max Y:      11222809.102523187

```

### BlobStores

```
Type:                   File BlobStore
Identifier:             cachestore
Enabled:                true
Default:                true
Base Directory:         /srv/data/tiles
File System Block Size: 4096
```

### Disk Quota

```
Enable disk quota
Disk quota check frequency: 60
Maximum tile cache size:    40 GiB
Use "Least frequently used"
Disk quota store type:      H2
```

Enabling the disk quota will allow tracking of disk space used as well.

### Tile Layers

For each layer group, edit the layer and select the "Tile Caching" tab. Enable the creation of a cached layer for the layer group. Remove all the default gridsets, and add the gridset for that specific layer group's CRS.

Additionally, follow the same procedure for both of the "Soper's Map" layers.

Once done, these layers should be listed under the "Tile Layers" main menu item. For each item, select "Seed/Truncate" to open a new window/tab. Use the following options:

```
Tasks:      2
Type:       Seed
Grid Set:   (Default)
Format:     image/jpeg
Zoom start: 00
Zoom stop:  06

Bounding Box: Use the same as the gridset bounds
```

This will take a few minutes. You can continue adding other layers to the queue, and the tile generator will eventually get to them.

Go ahead and repeat the tile seed configuration for `image/png` as well, then again for each layer.

Zoom 0 – 6 with 2 tasks on a cloud server will take around 25 minutes to complete per layer per image format.

### Testing Tiles

From the main GeoServer web page (`/geoserver/web`), copy the WMTS Service Capabilities link, and use that for adding WMTS to QGIS. The maps should show up as an option in the source data list. Try adding one of the layers for which you generated tiles, and notice how much faster the tiles are then WMS.
