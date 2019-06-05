# Proxy Setting
default["apt"]["http_proxies"]  = []
default["apt"]["http_direct"]   = []
default["apt"]["https_proxies"] = []
default["apt"]["https_direct"]  = ["download.docker.com", "packagecloud.io"]
default["apt"]["ftp_proxies"]   = []
default["apt"]["ftp_direct"]    = []

# Chef Node Settings
# ID (or partial ID) of volume mounted for docker storage.
# A zpool will be auto-created for this volume. 
default["sarcee"]["docker_volume_id"] = "8d5aad47-32db-4775-8"
# Source for EOL sites repository
default["sarcee"]["eol_sites_repository"] = "https://github.com/GeoSensorWebLab/eol-sites"
# Original login user
default["sarcee"]["user"] = "ubuntu"
# List of keys to allow for EOL site commits
default["gpg"]["import_keys"] = ["https://keybase.io/jamesbadger/pgp_keys.asc"]

# Make sure these apps exist in Dokku.
# Does not deploy the apps, just creates the skeletons.
default["dokku"]["apps"] = [
  {
    name: "abm-portal",
    domains: %w(sightings.arcticconnect.org sightings.arcticconnect.ca arctic-bio-map.gswlab.ca)
  },
  {
    name: "arctic-portal",
    domains: %w(portal.arcticconnect.org portal.arcticconnect.ca arctic-portal.gswlab.ca)
  },
  {
    name: "arctic-scholar-portal",
    domains: %w(records.arcticconnect.org records.arcticconnect.ca arctic-scholar.gswlab.ca)
  },
  {
    name: "arctic-web-map-pages",
    domains: %w(webmap.arcticconnect.org webmap.arcticconnect.ca arctic-web-map-pages.gswlab.ca arctic-web-map.gswlab.ca)
  },
  {
    name: "asw-workbench",
    domains: %w(sensorweb.arcticconnect.org aswp-dashboard.sensorup.org sensorweb.arcticconnect.ca arctic-sensor-web.gswlab.ca)
  },
  {
    name: "bera-dashboard",
    domains: %w(dashboard.bera-project.org)
  },
  {
    name: "sta-time-vis",
    domains: %w(visualize.gswlab.ca visualize.geocens.ca)
  },
  {
    name: "sta-webcam",
    domains: %w(webcam.gswlab.ca webcam.geocens.ca)
  },
]
# Location for the public key for dokku
default["dokku"]["keyfile"] = "/home/ubuntu/.ssh/id_rsa.pub"
