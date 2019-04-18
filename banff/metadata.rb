name             'banff'
maintainer       'The Authors'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures banff'
long_description 'Installs/Configures banff'
# issues_url 'https://github.com/<insert_org_here>/banff/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/banff' if respond_to?(:source_url)
version          '0.1.0'
privacy          true

# Public Cookbooks
depends 'acme', '~> 2.0.0'
depends 'apt'
depends 'user'

# Private Cookbooks
# depends 'gsw-apt-mirror'
