name             'blackfoot'
maintainer       'James Badger'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures blackfoot'
long_description 'Installs/Configures blackfoot'
# issues_url 'https://github.com/<insert_org_here>/gsw-chef/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/gsw-chef' if respond_to?(:source_url)
version          '1.0.0'
privacy          true

# Public Cookbooks
depends 'chef-vault'
depends 'nodejs', '~> 6.0.0'
depends 'postgresql'

# Private Cookbooks
# depends 'gsw-apt-mirror'
