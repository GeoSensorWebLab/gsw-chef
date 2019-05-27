# Data Preparation

Data processing will be done with QGIS 3.6 and with GDAL 2.4.1.

### About GeoPackages

I am using GeoPackage files instead of Shapefiles as it is easier to keep track of a single `.gpkg` file instead of a directory of files necessary for ESRI Shapefiles. GeoPackages also simplify file encoding by making UTF-8 mandatory.

### About GeoTIFFs

I use GeoTIFFs as they are the most common and easy to use file type for raster geo-data. The compression options are also decent and well supported by this project's tools (QGIS, GDAL, GeoServer). Compression not only decreases the file size, it makes the files faster to read from disk (which is a trade-off against CPU time).

### About Overviews

I recommend using overviews, especially for large raster images. I prefer external overviews, as it is easier to remove them and re-generate them with different options. Instructions on adding overviews to the rasters will be a part of the "Optimization" section of the ["GeoServer Setup" document](1_GEOSERVER_SETUP.markdown).

### About File Encodings

Some files may have UTF-8 encoding, others may use ISO-8859-1 encoding. This will only affect how text labels are displayed when rendered — the wrong encoding will display error characters. The "Data Processing" steps below will cover the datasets that must be converted to UTF-8.

## Data Processing

I recommend creating a new directory for intermediary files, and a new directory for all output files that are ready to upload for GeoServer.

```
/GIS
  /intermediate
  /for_upload
```

### ArcticDEM

We need to prepare six versions of this DEM:

1. The DEM clipped to the GSHHG coastline polygon, in `EPSG:3413`
2. A hillshade version of #1
3. A slope calculation version of #1
4. The DEM from #1 re-projected to `EPSG:4326`
5. A hillshade version of #4
6. A slope calculation version of #4

We create a set of rasters for `EPSG:3413` for the layers presented in polar projections, and a separate set of rasters for `EPSG:4326` and the layers presented in Mercator projections. This is necessary as GeoServer will be very slow in re-projecting the rasters on-the-fly from polar to Mercator.

I recommend making a backup of the original DEM, to prevent accidental overwriting.

#### ArcticDEM `EPSG:3413` Processing

Open the `GSHHS_shp/f/GSHHS_f_L1.shp` coastline polygon in QGIS.

In the Processing Toolbox use "Fix Geometries". Create a temporary layer.

In the Processing Toolbox use "Clip Vector by Extent". Use `-180, 180, 40, 90 [EPSG:4326]` as the "Clipping extent".

In the Processing Toolbox use "Densify by Interval". Set the interval to `0.5` (corresponding to 0.5 degrees of latitude or longitude).

Set the project projection to `EPSG:3413`. You should see a clean arc for the edge of the extent across the USA and Asia.

In the Processing Toolbox use "Reproject Layer". Set the Target CRS to `EPSG:3413`. (This also changes the units to metres, which we want for a fixed resolution.)

In the Processing Toolbox, use "Rasterize (Vector to Raster)". Use the following options:

```
Input Layer:                    Reprojected [EPSG:3413]
Field to use for a burn-in value: (Empty)
A fixed value to burn:          1.0
Output raster size units:       Georeferenced units
Width/Horizontal Resolution:    50
Height/Vertical Resolution:     50
Output extent:                  … -> Use extent from "Reprojected"

Advanced Parameters
Creation Option:                COMPRESS=PACKBITS
Creation Option:                NUM_THREADS=ALL_CPUS
Output data type:               Byte
```

This creates a 50 metre resolution raster of the coastline; a higher-resolution raster will create a "cleaner" coastline for the ArcticDEM but will also take longer. (For reference, on a high-end desktop, 100 metres takes 5 minutes; 75 metres takes 7 minutes; 50 metres takes 10 minutes.)

After the raster is created, open the 500 metre ArcticDEM in QGIS.

In the "Raster" menu, open the "Raster Calculator". Set the expression to `(rasterized > 0) * arcticdem_500m`. This will copy the ArcticDEM but only in pixels where the rasterized coastline polygon has a value. Set the output layer to save as `arcticDEM_500_clipped.tif` in the `intermediate` directory, with Output CRS `EPSG:3413`.

In the Processing Toolbox, open "Translate (Convert Format)" from GDAL. We will apply compression to the raster to decrease the file size. Select the raster as the input layer, and set the Profile to `High compression`. Save to a GeoTIFF named `arcticDEM_500_3413.tif` in the `intermediate` directory.

Remove all layers aside from the one you just created.

In the Processing Toolbox, open "Hillshade" from GDAL. Use the following options:

```
Input Layer:                arcticDEM_500_3413
Z factor:                   1.5
Azimuth:                    315
Altitude:                   45
Multidirectional Shading:   Enabled
Profile:                    High compression
Add Creation Option "TILED=YES"
```

Save the file to `intermediate/arcticDEM_500_3413_hillshade.tif`.

In the Processing Toolbox, open "Slope" from GDAL. Use the following options:

```
Input Layer:                arcticDEM_500_3413
Profile:                    High compression
Add Creation Option "TILED=YES"
```

Save the file to `intermediate/arcticDEM_500_3413_slope.tif`.

Next, use "Translate (Convert Format)" to convert these three rasters to GeoTIFFs in the `for_upload` directory, with the following options:

```
Profile:            High compression
Add Creation Option "TILED=YES"
Output data type:   Int16
```

This step is done so that GeoServer will properly read the rasters; it will not read `Float32` rasters in version 2.15.2 (bug?).

#### ArcticDEM `EPSG:4326` Processing

Similar to the process for `EPSG:3413`.

Open the `GSHHS_shp/f/GSHHS_f_L1.shp` coastline polygon in QGIS.

In the Processing Toolbox use "Fix Geometries". Create a temporary layer.

In the Processing Toolbox use "Clip Vector by Extent". Use `-180, 180, 40, 90 [EPSG:4326]` as the "Clipping extent".

In the Processing Toolbox, use "Rasterize (Vector to Raster)". Use the following options:

```
Input Layer:                    Clipped [EPSG:4326]
Field to use for a burn-in value: (Empty)
A fixed value to burn:          1.0
Output raster size units:       Georeferenced units
Width/Horizontal Resolution:    0.0001
Height/Vertical Resolution:     0.0001
Output extent:                  … -> Use extent from "Reprojected"

Advanced Parameters
Creation Option:                COMPRESS=PACKBITS
Creation Option:                NUM_THREADS=ALL_CPUS
Output data type:               Byte
```

This creates a 50 metre resolution raster of the coastline. Rename the layer as `coastline_50`. After the raster is created, open the 500 metre ArcticDEM in QGIS.

Open the Processing Toolbox and use "Warp (Reproject)" from GDAL. Use the following options:

```
Source CRS:             EPSG:3413
Target CRS:             EPSG:4326
Resampling:             Bilinear
Output File Resolution: 0.01
Profile:                High compression
Georeferenced Extents:  Use Layer Extent: Coastline raster
```

`0.01` takes awhile to process. Rename the output layer as `arcticDEM_4326`.

In the "Raster" menu, open the "Raster Calculator". Set the expression to `(coastline_50 > 0) * arcticdem_4326`. Set the output layer to save as `arcticDEM_500_4326_clipped.tif` in the `intermediate` directory, with Output CRS `EPSG:4326`.

In the Processing Toolbox, open "Translate (Convert Format)" from GDAL. We will apply compression to the raster to decrease the file size. Select the raster as the input layer, and set the Profile to `High compression`. Save to a GeoTIFF named `arcticDEM_500_4326.tif` in the `intermediate` directory.

Remove all layers aside from the one you just created.

In the Processing Toolbox, open "Hillshade" from GDAL. Use the following options:

```
Input Layer:                arcticDEM_500_4326
Z factor:                   1.5
Azimuth:                    315
Altitude:                   45
Multidirectional Shading:   Enabled
Profile:                    High compression
Add Creation Option "TILED=YES"
```

Save the file to `intermediate/arcticDEM_500_4326_hillshade.tif`.

In the Processing Toolbox, open "Slope" from GDAL. Use the following options:

```
Input Layer:                arcticDEM_500_4326
Profile:                    High compression
Add Creation Option "TILED=YES"
```

Save the file to `intermediate/arcticDEM_500_4326_slope.tif`.

Next, use "Translate (Convert Format)" to convert these three rasters to GeoTIFFs in the `for_upload` directory, with the following options:

```
Profile:            High compression
Add Creation Option "TILED=YES"
Output data type:   Int16
```

This step is done so that GeoServer will properly read the rasters; it will not read `Float32` rasters in version 2.15.2 (bug?).

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

### Dewey Soper's Hand Drawn Map

The non-georeferenced TIFF image will have to be registered in QGIS. Please review [the QGIS guide to georeferencing](https://www.qgistutorials.com/en/docs/3/georeferencing_basics.html) before starting. Note that in some versions of QGIS the plugin for "Georeferencer" will not show its checkbox in the plugin list, as the checkbox is invisible; you have to click where the checkbox is *supposed* to be to enable the checkbox.

Use the Georeferencer to open the original TIFF image. Select `EPSG:102002` as the target CRS. Optionally, load the Ground Control Points (GCPs) from the `files/default` directory in this Chef cookbook.

With the GCPs loaded, select the "Gear" icon and use the following options:

```
Transformation type:        Polynomial 2
Resampling method:          Lanczos
Target SRS:                 EPSG:4326
Output raster:              soper_4326.tif
```

Select OK, then select the "Play" or "Transform" icon to run the transformation. This will add a layer to the map. (I had to reload QGIS before the layer would display properly.)

Go ahead and modify the options to create an `EPSG:3413` tiff file as well, then run the transform to create the raster.

Remove both layers from QGIS. Open a terminal and install the `libgeotiff` tools for your OS, then `cd` to the directory with the geotiffs. Next we will edit the TIFF files to create an alpha mask (this removes the black borders around the re-projected image), but first we need to dump the geotiff data so we can re-apply it after editing.

```terminal
$ listgeo -no_norm "soper_3413.tif" > soper_3413.geo
$ listgeo -no_norm "soper_4326.tif" > soper_4326.geo
```

Next open the TIFF files in Photoshop or a similar image editor that can support Alpha Channels. Use the "Wand" tool to select the black border around the image, invert the selection, and in the Channels palette select "Save selection as channel". Save as a NEW file using "Save as…" and give the file a new name. Make sure "Alpha Channels" is enabled. Do not bother with image compression (select "none"), as we will re-compress with QGIS later.

Do this for both `EPSG:3413` and `EPSG:4326` images. Quit Photoshop.

Back in the terminal, we will re-apply the geodata to the TIFF files.

```terminal
$ geotifcp -g soper_3413.geo soper_3413_2.tif soper_3413_alpha.tif
$ geotifcp -g soper_4326.geo soper_4326_2.tif soper_4326_alpha.tif
```

Open the `soper_3413_alpha.tif` in QGIS, and it should display in the correct location. Open the layer properties, and in the transparency tab select "Band 4" as the transparency band. Now the black border around the image will be removed for rendering in QGIS. (GeoServer will automatically read band 4 as the alpha layer.)

In the Processing Toolbox, select "Translate (Convert Format)" to convert the image for upload. Use the following options:

```
Profile:            High compression
Add Creation Option "TILED=YES"
```

Save the file in the `for_upload` directory, and do the same for the `soper_4326_alpha.tif` file.

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

### Map Background

In QGIS, open "Create Layer from Extent" from the Processing Toolbox. For the extent, use `-180,180,40,90 [EPSG:4326]` and save as a temporary layer.

Open "Densify by Interval" from the Processing Toolbox and set the interval to `0.5`.

Save the "Densified" layer as a new file with the following settings:

```
Format:     GeoPackage
File name:  background.gpkg
Layer name: Map Background
CRS:        EPSG:4326
Description:
Map background for gap mask.
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

### Natural Earth Data Bathymetry

We will need to join all the layers into a single layer, fix geometries, clip to the bounds of our project, densify, and export to a GeoPackage file. Note that "deeper" layer polygons must sit above lower-depth polygons for rendering to work correctly; the sort order can be modified in GeoServer later.

The first step is to make sure all the layers are using the same data type; some are using `Integer`, others `Integer64`. For the following layers:

* `ne_10m_bathymetry_L_0`
* `ne_10m_bathymetry_E_6000`

Open the Processing Toolbox and select "Convert Format" under "GDAL - Vector". In the dialog that opens, add `-mapFieldType Integer64=Integer` to the "Additional creation options", and save to a temporary file. After creating the "Converted" layer, rename it as the original layer and remove the original layer from QGIS.

In the Processing Toolbox, select "Merge Vector Layers" from "QGIS" (not SAGA). Select all the layers as input and make sure they are sorted from 10000 to 0. Set the destination CRS to `EPSG:4326`.

The resulting layer will contain all the polygons in a multi-polygon layer, and the rendering will show only the 0-depth bathymetry layer. You can check that the other layers are still working by editing the layer Symbology, expanding "Layer Rendering", enabling "Control feature rendering order", and sort by `depth` ascending (draw low depths first, then deeper layers on top).

**Note:** It may be possible at this point to simplify the geometries and remove overlapping polygons (as lower depths won't be rendered where a higher depth exists). I chose not to do this as it would make the geometries of the lower depth polygons more complex.

Select the "Merged" combined layer, and in the Processing Toolbox select "Fix Geometries". This may fix some issues that could affect rendering later.

Select the "Fixed geometries" layer, and run "Clip Vector by Extent". Use `-180, 180, 40, 90 [EPSG:4326]` as the "Clipping extent".

Select the "Clipped (extent)" layer and use "Densify by Interval". Set the interval to `0.5` (corresponding to 0.5 degrees of latitude or longitude).

With the "Densified" layer, save as a new file with the following settings:

```
Format:     GeoPackage
File name:  bathymetry.gpkg
Layer name: Bathymetry
CRS:        EPSG:4326
Description:
Natural Earth Data bathymetry layers.
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

### Natural Earth Data Graticules

Import `ne_10m_graticules_15.shp` into QGIS.

In the Processing Toolbox use "Clip Vector by Extent". Use `-180, 180, 40, 90 [EPSG:4326]` as the "Clipping extent". Save to a temporary file.

Densification is not necessary as the layer has already been pre-densified.

Go to the "Layer" menu and select "Save As…".

```
Format:     GeoPackage
File name:  graticules.gpkg
Layer name: graticules
CRS:        EPSG:4326
Description:
Natural Earth Data 15-degree graticules layer.
```

Leave other options as default. Save the file in your `for_upload` directory. Discard all layers in GeoServer.

### North American Atlas: Glaciers

Save the layer as a new file, with the following settings:

```
Format:     GeoPackage
File name:  glaciers.gpkg
Layer name: glaciers
CRS:        EPSG:4326
Description:
Permanent glaciers data from North American Atlas Glaciers dataset, published in 2011.
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
