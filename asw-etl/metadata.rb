name             'asw-etl'
maintainer       'James Badger'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures asw-etl'
long_description 'Installs/Configures Arctic Sensor Web "Extract, Transform, Load" scheduled service'
issues_url       'https://github.com/GeoSensorWebLab/gsw-chef/issues' if respond_to?(:issues_url)
source_url       'https://github.com/GeoSensorWebLab/gsw-chef' if respond_to?(:source_url)
version          '1.0.0'
privacy          true

# Public Cookbooks
depends 'chef-vault'

# Private Cookbooks
# depends 'gsw-apt-mirror'
