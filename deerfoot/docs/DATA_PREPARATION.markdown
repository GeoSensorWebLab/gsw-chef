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

## About GeoPackages

I am using GeoPackage files instead of Shapefiles as it is easier to keep track of a single `.gpkg` file instead of a directory of files necessary for ESRI Shapefiles. GeoPackages also simplify file encoding by making UTF-8 mandatory.

## About GeoTIFFs

I use GeoTIFFs as they are the most common and easy to use file type for raster geo-data. The compression options are also decent and well supported by this project's tools (QGIS, GDAL, GeoServer).
