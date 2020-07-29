default["frost_server"]["deploy_postgis"] = true

default["frost_server"]["docker_repo"] = "fraunhoferiosb/frost-server"
default["frost_server"]["docker_tag"] = "latest"
# Environment variables passed to FROST Server
default["frost_server"]["env"] = {
  "http_cors_enable"               => "true",
  "http_cors_allowed.origins"      => "*",
  "persistence_db_driver"          => "org.postgresql.Driver",
  "persistence_db_url"             => "jdbc:postgresql://frost_server_database:5432/sensorthings",
  "persistence_db_username"        => "sensorthings",
  "persistence_db_password"        => "sample",
  "persistence_autoUpdateDatabase" => "true"
}
