default["postgresql"]["version"] = "11"
default["postgresql"]["data_directory"] = "/srv/data/postgresql/11/main"

# Prefix for all GOST binaries and configuration
default["gost"]["prefix"] = "/opt/gost"
# ZIP file with release of GOST to install
default["gost"]["release"] = "https://github.com/gost/server/releases/download/0.5/gost_ubuntu_x64.zip"
# Repository with database configuration scripts
default["gost"]["database_repository"] = "https://github.com/gost/gost-db.git"
# Name of postgresql database for GOST
default["gost"]["database"] = "gost"
# GOST system user must be the same as the GOST database user for ident
# access.
default["gost"]["user"] = "gost"
# The default advertised URL for entities in SensorThings API
default["gost"]["host_address"] = "sensors.arcticconnect.ca"
