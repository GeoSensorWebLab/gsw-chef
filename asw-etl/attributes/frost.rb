# Configuration for FROST instance
default["docker_compose"]["version"] = "1.24.1"

# This is the URL and path prefix that FROST will use for URLs in
# responses. This will affect the links that are sent to STA clients.
default["frost"]["service_root_url"] = "http://localhost:8080/FROST-Server"
