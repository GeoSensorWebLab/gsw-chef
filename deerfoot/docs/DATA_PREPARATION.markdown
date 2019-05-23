# Data Preparation

TODO: Guide on setting up data

* download the data sources
* manage the correct file encodings
* clip vectors to area of interest
* apply densification to vectors so they survive re-projection
* export vectors to GeoPackages
* convert coastline to raster, use raster to clip arcticDEM
* export arcticDEM to GeoTIFF (not Float32!) with compression
* Create hillshade
* Create slope raster
* Importing Soper's hand-drawn map and GCP points
* Projecting Soper's hand-drawn map to EPSG:3413 and EPSG:4326
* Exporting the map to GeoTIFF with proper masking
* create vector for map background

Data processing will be done with QGIS 3.6 and with GDAL 2.4.1.

## About GeoPackages

I am using GeoPackage files instead of Shapefiles as it is easier to keep track of a single `.gpkg` file instead of a directory of files necessary for ESRI Shapefiles. GeoPackages also simplify file encoding by making UTF-8 mandatory.

## About GeoTIFFs

I use GeoTIFFs as they are the most common and easy to use file type for raster geo-data. The compression options are also decent and well supported by this project's tools (QGIS, GDAL, GeoServer).

## About File Encodings

Some files may have UTF-8 encoding, others may use ISO-8859-1 encoding. This will only affect how text labels are displayed when rendered — the wrong encoding will display error characters. The "Data Processing" steps below will cover the datasets that must be converted to UTF-8.

## Data Sources

### GSHHG Coastline Shapefile (150 MB)

[Homepage](http://www.soest.hawaii.edu/pwessel/gshhg/)

GPLv3

A set of shapefiles for the world coastline. Also available are datasets for "World Data Bank" and "Atlas of the Cryosphere", but we only want the "World Vector Shorelines".

## Data Processing

I recommend creating a new directory for intermediary files, and a new directory for all output files that are ready to upload for GeoServer.

```
/GIS
  /intermediate
  /for_upload
```

### GSHHG Coastline

Import `GSHHS_shp/f/GSHHS_f_L1.shp` into QGIS.

In the Processing Toolbox use "Fix Geometries". Create a temporary layer.

In the Processing Toolbox use "Clip Vector by Extent". Use `-180, 180, 40, 90 [EPSG:4326]` as the "Clipping extent". Save to a temporary file.

In the Processing Toolbox use "Densify by Interval". Set the interval to `0.5` (corresponding to 0.5 degrees of latitude or longitude). Save to a temporary layer.

Go to the "Layer" menu and select "Save As…".

```
Format:     GeoPackage
File name:  coastline.gpkg
Layer name: coastline
CRS:        EPSG:4326
Description:
GSHHG World Vector Shorelines v2.3.7 modified under GPLv3.
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

## Metadata for GeoServer

Recommended metadata for the layer fields in GeoServer.

### GSHHG Coastline

```
Name:       coastline
Enabled:    true
Advertised: true
Title:      GSHHG Coastline
Abstract:
Coastline for area of interest.
GSHHG World Vector Shorelines v2.3.7 modified under GPLv3.
```

Advertising is enabled to comply with GPLv3 modification/redistribution terms.
