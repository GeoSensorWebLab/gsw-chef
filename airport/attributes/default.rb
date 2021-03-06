# Most of these attributes are directly copied from the `maps_server`
# cookbook's default attributes. The attributes here take precedence 
# over the ones in `maps_server`.

#########
## Locale
#########
default[:maps_server][:locale] = 'en_CA'

##################################
## Installation Directory Prefixes
##################################
# For software packages
default[:maps_server][:software_prefix] = '/opt'
# For map source data downloads
default[:maps_server][:data_prefix] = '/srv/data'
# For map stylesheets
default[:maps_server][:stylesheets_prefix] = '/srv/stylesheets'

#################
## Rendering User
#################
default[:maps_server][:render_user] = 'render'
