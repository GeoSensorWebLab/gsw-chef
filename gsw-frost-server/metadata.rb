name             'gsw-frost-server'
maintainer       'The Authors'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures gsw-frost-server'
long_description 'Installs/Configures gsw-frost-server'
# issues_url 'https://github.com/<insert_org_here>/gsw-frost-server/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/gsw-frost-server' if respond_to?(:source_url)
version          '0.1.0'
privacy          true

# Public Cookbooks
depends 'chef-vault'
depends 'docker'

# Private Cookbooks
# depends 'gsw-apt-mirror'
