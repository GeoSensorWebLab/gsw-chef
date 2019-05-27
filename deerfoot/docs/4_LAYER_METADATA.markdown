# Metadata for GeoServer

Recommended metadata for the layer fields in GeoServer.

## ArcticDEM

```
Name:       arcticdem_500m_3413
Enabled:    true
Advertised: false
Title:      ArcticDEM (EPSG:3413)
Abstract:
Modified version of ArcticDEM 500 metre mosaic clipped to GSHHG coastline data.

Geospatial support for this work provided by the Polar Geospatial Center under NSF-OPP awards 1043681 and 1559691.

DEMs provided by the Polar Geospatial Center under NSF-OPP awards 1043681, 1559691, and 1542736.

Porter, Claire; Morin, Paul; Howat, Ian; Noh, Myoung-Jon; Bates, Brian; Peterman, Kenneth; Keesey, Scott; Schlenk, Matthew; Gardiner, Judith; Tomko, Karen; Willis, Michael; Kelleher, Cole; Cloutier, Michael; Husby, Eric; Foga, Steven; Nakamura, Hitomi; Platson, Melisa; Wethington, Michael, Jr.; Williamson, Cathleen; Bauer, Gregory; Enos, Jeremy; Arnold, Galen; Kramer, William; Becker, Peter; Doshi, Abhijit; D’Souza, Cristelle; Cummens, Pat; Laurier, Fabien; Bojesen, Mikkel, 2018, “ArcticDEM”, https://doi.org/10.7910/DVN/OHHUKH, Harvard Dataverse, V1, [May 2019].
```

This metadata is re-used for `EPSG:4326` versions, and for the `hillshade` and `slope` rasters too.

## Canadian Geographical Names

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

## Dewey Soper's Hand Drawn Map

```
Name:       sopers_map_4326
Enabled:    true
Advertised: true
Title:      Dewey Soper's Hand Drawn Map (EPSG:4326)
Abstract:
Dewey Soper's Hand Drawn Map digitized for the Arctic Institute of North America.
```

```
Name:       sopers_map_3413
Enabled:    true
Advertised: true
Title:      Dewey Soper's Hand Drawn Map (EPSG:3413)
Abstract:
Dewey Soper's Hand Drawn Map digitized for the Arctic Institute of North America.
```

## GSHHG Coastline

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

## Map Background

```
Name:       background
Enabled:    true
Advertised: false
Title:      Map Background
Abstract:
Map background to mask any gaps between coastline and bathymetry layers.
```

## Natural Earth Data Bathymetry

```
Name:       bathymetry
Enabled:    true
Advertised: false
Title:      Bathymetry
Abstract:
Natural Earth Data 1:10,000,000 Bathymetry (merged layers).
```

## Natural Earth Data Graticules

```
Name:       graticules
Enabled:    true
Advertised: false
Title:      Graticules
Abstract:
Natural Earth Data Graticules in 15 degree intervals.
```

## North American Atlas: Glaciers

```
Name:       glaciers
Enabled:    true
Advertised: false
Title:      Glaciers
Abstract:
Permanent glaciers data from North American Atlas Glaciers dataset, published in 2011.
```

## North American Atlas: Lakes (Hydrography)

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

## North American Atlas: Rivers (Hydrography)

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
