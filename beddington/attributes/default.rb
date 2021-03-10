# Default user for the system. Should be overridden in .kitchen.yml for
# test-kitchen.
default["beddington"]["user"] = "ubuntu"

# ZFS filesystem quota (limit) for disk space allocated for Docker's
# internal storage driver.
default["beddington"]["docker_quota"] = "10G"

# Configuration for what version of Docker-Compose to download
default["docker_compose"]["version"] = "1.28.2"
default["docker_compose"]["sha256"] = "e984402b96bb923319f8ac95c8d26944e12d15692ab0fea4fff63ddfd5fd8d64"
default["docker_compose"]["os"] = "Linux"
default["docker_compose"]["arch"] = "x86_64"

# DokuWiki Configuration
# Title of the wiki.
default["dokuwiki"]["title"] = "ArcticConnect"
# Default license for wiki content. Available options:
# - cc-zero
#   (CC0 1.0 Universal)
# - publicdomain
#   (Public Domain)
# - cc-by
#   (CC Attribution 4.0 International)
# - cc-by-sa
#   (CC Attribution-Share Alike 4.0 International)
# - gnufdl
#   (GNU Free Documentation License 1.3)
# - cc-by-nc
#   (CC Attribution-Noncommercial 4.0 International)
# - cc-by-nc-sa
#   (CC Attribution-Noncommercial-Share Alike 4.0 International)
# - 0
#   (No license)
default["dokuwiki"]["license"] = "0"
# Emails sent from the Wiki will have this sender address.
default["dokuwiki"]["mailfrom"] = "internal-wiki@arcticconnect.ca"
# SMTP settings for sending email from the Wiki.
# (The username and password for SMTP are handled by Chef Vault.)
default["dokuwiki"]["smtp_host"] = "email-smtp.us-west-2.amazonaws.com"
default["dokuwiki"]["smtp_port"] = 587
default["dokuwiki"]["smtp_ssl"] = "tls"
default["dokuwiki"]["localdomain"] = "internal.arcticconnect.ca"
