name             'stoney'
maintainer       'The Authors'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures stoney'
long_description 'Installs/Configures stoney'
# issues_url 'https://github.com/<insert_org_here>/gsw-cookbook-template/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/gsw-cookbook-template' if respond_to?(:source_url)
version          '1.1.0'
privacy          true

# Public Cookbooks
depends 'docker', '5.0.0'

# Private Cookbooks
depends 'gsw-hostsfile'
