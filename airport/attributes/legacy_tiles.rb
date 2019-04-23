# Add stylesheet support to renderd for metatiles from the original
# tile server.
# 
# Note that the XML file is BLANK so that renderd will not try to render
# new tiles, as there is no database/stylesheet installed for this
# original style. Instead, metatiles from the original tile server can
# be served to clients for the tiles that were originally generated.
# 
# The metatiles were *manually* installed onto the server under the
# /srv/tiles directory:
#   /srv
#     /tiles
#       /osm_3571
#       /osm_3572
#       /osm_3573
#       /osm_3574
#       /osm_3575
#       /osm_3576
#
default["renderd"]["stylesheets"]["osm_3571"] = {
  description: "ArcticWebMap 3571",
  host:       "localhost",
  name:       "osm_3571",
  tiledir:    "/srv/tiles",
  tilesize:    256,
  uri:        "/osm_3571/",
  xml:        ""
}
default["renderd"]["stylesheets"]["osm_3572"] = {
  description: "ArcticWebMap 3572",
  host:       "localhost",
  name:       "osm_3572",
  tiledir:    "/srv/tiles",
  tilesize:    256,
  uri:        "/osm_3572/",
  xml:        ""
}
default["renderd"]["stylesheets"]["osm_3573"] = {
  description: "ArcticWebMap 3573",
  host:       "localhost",
  name:       "osm_3573",
  tiledir:    "/srv/tiles",
  tilesize:    256,
  uri:        "/osm_3573/",
  xml:        ""
}
default["renderd"]["stylesheets"]["osm_3574"] = {
  description: "ArcticWebMap 3574",
  host:       "localhost",
  name:       "osm_3574",
  tiledir:    "/srv/tiles",
  tilesize:    256,
  uri:        "/osm_3574/",
  xml:        ""
}
default["renderd"]["stylesheets"]["osm_3575"] = {
  description: "ArcticWebMap 3575",
  host:       "localhost",
  name:       "osm_3575",
  tiledir:    "/srv/tiles",
  tilesize:    256,
  uri:        "/osm_3575/",
  xml:        ""
}
default["renderd"]["stylesheets"]["osm_3576"] = {
  description: "ArcticWebMap 3576",
  host:       "localhost",
  name:       "osm_3576",
  tiledir:    "/srv/tiles",
  tilesize:    256,
  uri:        "/osm_3576/",
  xml:        ""
}
