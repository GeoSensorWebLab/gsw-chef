name             'beddington'
maintainer       'The Authors'
maintainer_email 'jpbadger@ucalgary.ca'
license          'Apache-2.0'
description      'Installs/Configures beddington node'
long_description 'Installs/Configures beddington node'
# issues_url 'https://github.com/<insert_org_here>/gsw-cookbook-template/issues' if respond_to?(:issues_url)
# source_url 'https://github.com/<insert_org_here>/gsw-cookbook-template' if respond_to?(:source_url)
version          '0.1.0'
privacy          true

# Public Cookbooks
# Docker cookbook v5 is used as we are not using Chef Infra v15 yet
depends 'docker', '~> 5.0'

# Private Cookbooks
# depends 'gsw-apt-mirror'
