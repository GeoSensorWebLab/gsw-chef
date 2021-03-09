# ZFS filesystem quota (limit) for disk space allocated for Docker's
# internal storage driver.
default["beddington"]["docker_quota"] = "10G"

# Configuration for what version of Docker-Compose to download
default["docker_compose"]["version"] = "1.28.2"
default["docker_compose"]["sha256"] = "e984402b96bb923319f8ac95c8d26944e12d15692ab0fea4fff63ddfd5fd8d64"
default["docker_compose"]["os"] = "Linux"
default["docker_compose"]["arch"] = "x86_64"
