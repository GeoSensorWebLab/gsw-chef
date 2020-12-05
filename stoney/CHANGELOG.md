# Changelog for stoney

## v1.1.0

* Replace `certbot-auto` with `certbot` installed via snap
* Lock the version of the `docker` cookbook dependency to `5.0.0` as newer versions require an upgrade of Chef Client which I don't have time for

## v1.0.0

Stable release of cookbook.

* Send additional headers from clients through the proxy to destination servers
* Use short timeout when upstream servers are unavailable to show errors faster
* Fetch HTTPS certificates automatically from Let's Encrypt
* Switch to using hostsfile cookbook
* Upgrade to Ruby 2.7.0 and unlock Chef/test-kitchen gems

## v0.1.0

