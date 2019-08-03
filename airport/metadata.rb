name             'airport'
maintainer       'The Authors'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures airport'
long_description 'Installs/Configures airport'
# issues_url 'https://github.com/<insert_org_here>/airport/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/airport' if respond_to?(:source_url)
version          '0.3.0'
privacy          true

# Public Cookbooks
# depends 'user'

# Private Cookbooks
depends 'maps_server', '~> 0.3.0'
