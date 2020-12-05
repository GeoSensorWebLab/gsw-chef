#!/bin/bash
set -e

if [ ! -z bootstrap_complete ]; then
	echo "Bootstrap already completed. Re-run is unstable."
	exit 1
fi

export DEBIAN_FRONTEND="noninteractive"

# Update packages
sudo apt update
sudo apt upgrade -y

# Install Chef Infra Server
wget --timestamping --continue \
	"https://packages.chef.io/files/stable/chef-server/12.18.14/ubuntu/18.04/chef-server-core_12.18.14-1_amd64.deb"

sudo dpkg --install --refuse-downgrade --skip-same-version \
	"chef-server-core_12.18.14-1_amd64.deb"

# https://docs.chef.io/chef_license_accept/
sudo chef-server-ctl reconfigure --chef-license=accept

# Turn off Chef Infra Server so certbot can run its own webserver
sudo chef-server-ctl stop

# Install certbot
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Activate certbot
sudo certbot certonly \
	--standalone \
	--non-interactive \
	--agree-tos \
	--email "jpbadger@ucalgary.ca" \
	--domain "chef.gswlab.ca" \
	--expand

# Update Chef Infra Server to use new certs
cat <<EOF | sudo tee "/etc/opscode/chef-server.rb"
nginx['ssl_certificate'] = '/etc/letsencrypt/live/chef.gswlab.ca/fullchain.pem'
nginx['ssl_certificate_key'] = '/etc/letsencrypt/live/chef.gswlab.ca/privkey.pem'
EOF

# Set up auto-renewal using certbot
sudo certbot renew \
	--pre-hook "chef-server-ctl stop" \
	--post-hook "chef-server-ctl start"

# Make sure hooks run by auto-renewal too
sudo sh -c 'printf "#!/bin/sh\nchef-server-ctl stop\n" > /etc/letsencrypt/renewal-hooks/pre/chef.sh'
sudo sh -c 'printf "#!/bin/sh\nchef-server-ctl start\n" > /etc/letsencrypt/renewal-hooks/post/chef.sh'

# Start up Chef Infra Server, picking up changes to chef-server.rb
sudo chef-server-ctl reconfigure
sudo chef-server-ctl start

# Install AWS CLI
sudo snap install aws-cli --classic

# Output runfile to prevent re-runs
date --utc --iso-8601=seconds > bootstrap_complete
