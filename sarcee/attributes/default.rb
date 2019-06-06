###################
# Apt Proxy Setting
###################

default["apt"]["http_proxies"]  = []
default["apt"]["http_direct"]   = []
default["apt"]["https_proxies"] = []
default["apt"]["https_direct"]  = ["download.docker.com", "packagecloud.io"]
default["apt"]["ftp_proxies"]   = []
default["apt"]["ftp_direct"]    = []

####################
# Chef Node Settings
####################

# ID (or partial ID) of volume mounted for docker storage.
# A zpool will be auto-created for this volume. 
default["sarcee"]["docker_volume_id"] = "d6899d6b-c3b3-43c5-9"
# Source for EOL sites repository
default["sarcee"]["eol_sites_repository"] = "https://github.com/GeoSensorWebLab/eol-sites"
# Original login user
default["sarcee"]["user"] = "ubuntu"
# List of keys to allow for EOL site commits
default["gpg"]["import_keys"] = ["https://keybase.io/jamesbadger/pgp_keys.asc"]

#####################
# Dokku Configuration
#####################

# Location for the public key for dokku
default["dokku"]["keyfile"] = "/home/ubuntu/.ssh/id_rsa.pub"
