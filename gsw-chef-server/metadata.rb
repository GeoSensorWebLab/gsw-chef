name             'gsw-chef-server'
maintainer       'The Authors'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures gsw-chef-server'
long_description 'Installs/Configures gsw-chef-server'
# issues_url 'https://github.com/<insert_org_here>/chef-server/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/chef-server' if respond_to?(:source_url)
version          '1.0.0'
privacy          true

# Public Cookbooks
depends 'chef-server-with-letsencrypt'

# Private Cookbooks
# depends 'gsw-apt-mirror'
