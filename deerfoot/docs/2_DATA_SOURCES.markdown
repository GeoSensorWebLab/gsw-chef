# Data Sources

## ArcticDEM 500 metre mosaic (382 MB)

[Homepage](https://www.pgc.umn.edu/data/arcticdem/)

Copyright, acknowledgement, and citation:

```
Geospatial support for this work provided by the Polar Geospatial Center under NSF-OPP awards 1043681 and 1559691.

DEMs provided by the Polar Geospatial Center under NSF-OPP awards 1043681, 1559691, and 1542736.

Porter, Claire; Morin, Paul; Howat, Ian; Noh, Myoung-Jon; Bates, Brian; Peterman, Kenneth; Keesey, Scott; Schlenk, Matthew; Gardiner, Judith; Tomko, Karen; Willis, Michael; Kelleher, Cole; Cloutier, Michael; Husby, Eric; Foga, Steven; Nakamura, Hitomi; Platson, Melisa; Wethington, Michael, Jr.; Williamson, Cathleen; Bauer, Gregory; Enos, Jeremy; Arnold, Galen; Kramer, William; Becker, Peter; Doshi, Abhijit; D’Souza, Cristelle; Cummens, Pat; Laurier, Fabien; Bojesen, Mikkel, 2018, “ArcticDEM”, https://doi.org/10.7910/DVN/OHHUKH, Harvard Dataverse, V1, [May 2019].
```

I chose to use the 500 metre mosaic as higher resolutions require considerably more space (100 metre is 7.8 GB). There are some gaps in the coverage, where underlying layers will be shown. The GSHHG coastline polygon is styled to minimize the appearance of these gaps.

## Canadian Geographical Names (31 MB)

[Homepage](https://www.nrcan.gc.ca/earth-sciences/geography/place-names/data/9245)

No license listed; possible [Open Government License](https://open.canada.ca/en/open-government-licence-canada)

Multiple sets of geo-files (CSV, SHP, KML, GML) for provinces, territories, and the entire country. For this project I downloaded the Shapefiles for all of Canada as we need Nunavut, Quebec, and Newfoundland and Labrador.

## Dewey Soper's Hand Drawn Map (35 MB)

Original format is a 35 MB TIFF (non-geo) at 600 ppi. Please contact someone from AINA for access to the original image.

## GSHHG Coastline Shapefile (150 MB)

[Homepage](http://www.soest.hawaii.edu/pwessel/gshhg/)

GPLv3

A set of shapefiles for the world coastline. Also available are datasets for "World Data Bank" and "Atlas of the Cryosphere", but we only want the "World Vector Shorelines".

## Map Background

A single polygon created to mask any holes between the bathymetry data and the ArcticDEM and coastline data.

## Natural Earth Data Bathymetry (16 MB)

[Homepage](https://www.naturalearthdata.com/downloads/10m-physical-vectors/10m-bathymetry/)

Public Domain

Optional attribution: "Made with Natural Earth. Free vector and raster map data @ naturalearthdata.com."

Includes 12 shapefiles for different ocean depths.

## Natural Earth Data Graticules (15 degree increments) (77 KB)

[Homepage](https://www.naturalearthdata.com/downloads/10m-physical-vectors/10m-graticules/)

Public Domain

Optional attribution: "Made with Natural Earth. Free vector and raster map data @ naturalearthdata.com."

## North American Atlas: Glaciers (2 MB)

[Homepage](http://ftp.geogratis.gc.ca/pub/nrcan_rncan/vector/framework_cadre/North_America_Atlas10M/glaciers/)

No license listed.

Contains a shapefile for glacier polygons that cover all of North America, Greenland, and Iceland. This is a revised version of the 2004 data set.

## North American Atlas: Hydrography (13 MB)

[Homepage](http://www.cec.org/tools-and-resources/map-files/lakes-and-rivers-2009)

No license listed.

Contains two sets of shapefiles, one for rivers and one for lakes and both files cover all of North America. This is a revised version of the 2006 data set.
