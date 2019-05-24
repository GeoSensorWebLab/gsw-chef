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

### Canadian Geographical Names (31 MB)

[Homepage](https://www.nrcan.gc.ca/earth-sciences/geography/place-names/data/9245)

No license listed; possible [Open Government License](https://open.canada.ca/en/open-government-licence-canada)

Multiple sets of geo-files (CSV, SHP, KML, GML) for provinces, territories, and the entire country. For this project I downloaded the Shapefiles for all of Canada as we need Nunavut, Quebec, and Newfoundland and Labrador.

### GSHHG Coastline Shapefile (150 MB)

[Homepage](http://www.soest.hawaii.edu/pwessel/gshhg/)

GPLv3

A set of shapefiles for the world coastline. Also available are datasets for "World Data Bank" and "Atlas of the Cryosphere", but we only want the "World Vector Shorelines".

### North American Atlas: Hydrography (13 MB)

[Homepage](http://www.cec.org/tools-and-resources/map-files/lakes-and-rivers-2009)

No license listed.

Contains two sets of shapefiles, one for rivers and one for lakes and both files cover all of North America. This is a revised version of the 2006 data set.

## Data Processing

I recommend creating a new directory for intermediary files, and a new directory for all output files that are ready to upload for GeoServer.

```
/GIS
  /intermediate
  /for_upload
```

### Canadian Geographical Names

The dataset is already encoded as UTF-8. Save the layer as a new file, with the following settings:

```
Format:     GeoPackage
File name:  placenames.gpkg
Layer name: placenames
CRS:        EPSG:4326
Description:
Canadian Geographical Names v2.0
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

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

### North American Atlas: Lakes (Hydrography)

**Important:** This shapefile uses `ISO-8859-1` encoding. After opening the file in QGIS, open the layer properties and change the encoding to `ISO-8859-1`. Then when you open the attribute table, you should see correctly parsed accents in French words such as "Lake Erie/Lac Érié".

Save the layer as a new file, with the following settings:

```
Format:     GeoPackage
File name:  lakes.gpkg
Layer name: lakes
CRS:        EPSG:4326
Description:
Lakes data from North American Atlas Hydrography dataset, published in 2010.
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

### North American Atlas: Rivers (Hydrography)

**Important:** This shapefile uses `ISO-8859-1` encoding. After opening the file in QGIS, open the layer properties and change the encoding to `ISO-8859-1`. Then when you open the attribute table, you should see correctly parsed accents in French words such as "Rivière Saint-Jean".

Save the layer as a new file, with the following settings:

```
Format:     GeoPackage
File name:  rivers.gpkg
Layer name: rivers
CRS:        EPSG:4326
Description:
River data from North American Atlas Hydrography dataset, published in 2010.
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

## Metadata for GeoServer

Recommended metadata for the layer fields in GeoServer.

### Canadian Geographical Names

```
Name:       cgn_canada_eng
Enabled:    true
Advertised: false
Title:      Canadian Geographical Names
Abstract:
Canadian Geographical Names v2.0 dataset, only showing Nunavut, Quebec, and Newfoundland and Labrador. Lake/rivers are excluded and labelled in a different dataset.

Restrict the features on layer by CQL filter:

"PROV_TERR" IN ('Nunavut','Quebec','Newfoundland and Labrador') AND "GENERIC" NOT IN ('River','River Junction','River Mouth','River Segment','Rivers','Artificial Lake','Artificial Lakes','Lake','Lakes','Part of  a Lake','Part of a Lake') AND LANGUAGE NOT IN ('French')
```

The CQL filter will only show places in certain provinces/territories, will hide rivers/lakes/similar features, and not display French placenames. French is not shown as duplicate points exist for the same feature in multiple languages, and GeoServer sometimes renders different languages at different zoom levels and I have not had any luck getting sorting or priority to work in the stylesheet.

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

### North American Atlas: Lakes (Hydrography)

```
Name:       hydrography_lakes
Enabled:    true
Advertised: false
Title:      Lakes
Abstract:
Lakes data from North American Atlas Hydrography dataset, published in 2010.

Restrict the features on layer by CQL filter:

"COUNTRY"  LIKE 'CAN'  AND "TYPE"  = 16
```

The CQL filter will only show features in Canada, and of type 16 — this excludes the ocean, water boundary lines, coastlines (GSHHG is higher quality), rivers/streams, intermittent streams, and the dataset limit boundary.

### North American Atlas: Rivers (Hydrography)

```
Name:       hydrography_rivers
Enabled:    true
Advertised: false
Title:      Rivers
Abstract:
River data from North American Atlas Hydrography dataset, published in 2010.

Restrict the features on layer by CQL filter:

"COUNTRY"  LIKE  'CAN' AND "TYPE"  = 17
```

The CQL filter will only show features in Canada, and of type 17 (rivers/streams).
