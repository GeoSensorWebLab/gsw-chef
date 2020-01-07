# Changelog for sarcee

## v1.0.0

* Deploy "End of Life" web pages for web applications we are not actively maintaining
* Set up empty apps using Dokku so that the full apps can be pushed later
* Set up virtual hosts for hosted applications using attributes file
* Disable web setup interface for Dokku
* Automatically run docker cleanup scripts using cron
* Use a ZFS volume for Docker for stability and ease of cleanup
* Load hosted application configuration from encrypted data bags for setting up database access credentials
* Upgrade to use Ruby 2.7.0

## v0.1.0

* Initial cookbook release
