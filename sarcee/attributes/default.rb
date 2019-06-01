# Proxy Setting
default["apt"]["http_proxies"]  = []
default["apt"]["http_direct"]   = []
default["apt"]["https_proxies"] = []
default["apt"]["https_direct"]  = ["download.docker.com", "packagecloud.io"]
default["apt"]["ftp_proxies"]   = []
default["apt"]["ftp_direct"]    = []

# Chef Node Settings
default["sarcee"]["eol_sites_repository"] = "https://github.com/GeoSensorWebLab/eol-sites"

default["gpg"]["import_keys"] = ["https://keybase.io/jamesbadger/pgp_keys.asc"]

# Make sure these apps exist in Dokku.
# Does not deploy the apps, just creates the skeletons.
default["dokku"]["apps"] = [
  { name: "abm-portal" },
  { name: "arctic-portal" },
  { name: "arctic-scholar-portal" },
  { name: "arctic-web-map-pages" },
  { name: "asw-workbench" },
  { name: "bera-dashboard" },
  { name: "sta-time-vis" },
  { name: "sta-webcam" }
]
